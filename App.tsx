import React, { useRef, useState, useEffect } from 'react';
import { Alert, StyleSheet, View, Text } from 'react-native';
import Settings from './src/ui/Settings';
import { theme as themeNameValue, loadTheme } from './src/state/theme';
import { colors } from './src/styles/tokens';
import { loadSpeechEnabled } from './src/state/speech';
import type MapView from 'react-native-maps';
import { MapPressEvent, LongPressEvent, UserLocationChangeEvent, LatLng } from 'react-native-maps';
import DrivingHUD from './src/features/navigation/ui/DrivingHUD';
import LightFormModal from './src/features/traffic/ui/LightFormModal';
import CycleFormModal from './src/features/traffic/ui/CycleFormModal';
import SpeedBanner from './src/features/navigation/ui/SpeedBanner';
import MapViewWrapper from './src/ui/MapViewWrapper';
import MenuContainer from './src/ui/MenuContainer';
import LogViewer from './src/features/logs/LogViewer';
import { supabase } from './src/services/supabase';
import { useSupabaseData } from './src/hooks/useSupabaseData';
import { useMenu } from './src/hooks/useMenu';
import { getRoute, RouteStep } from './src/features/navigation/services/ors';
import {
  saveRoute,
  loadRoute,
} from './src/features/navigation/services/routeCache';
import i18n from './src/i18n';
import { projectLightsToRoute } from './src/domain/matching';
import { analytics } from './src/services/analytics';
import { notifyGreenPhase } from './src/services/notifications';
import {
  handleStartNavigation as startNavigation,
  handleClearRoute as clearRoute,
  computeRecommendation,
  LightOnRoute,
} from './src';
import { loadLeadTimeSec, leadTimeSec } from './src/state/leadTime';
import type { Light, LightCycle } from './src/domain/types';

interface Car {
  latitude: number;
  longitude: number;
  heading: number;
  speed: number;
}

export default function App(): JSX.Element {
  const mapRef = useRef<MapView | null>(null);
  const [car, setCar] = useState<Car | null>(null);
  const {
    lights,
    cycles,
    error: supabaseError,
    setLights,
    setCycles,
  } = useSupabaseData();
  const loadError = supabaseError ? 'Failed to load data' : null;
  const [nowSec, setNowSec] = useState<number>(Math.floor(Date.now() / 1000));
  const [route, setRoute] = useState<LatLng[] | null>(null);
  const [lightsOnRoute, setLightsOnRoute] = useState<LightOnRoute[]>([]);
  const [recommended, setRecommended] = useState<number>(0);
  const [nearestInfo, setNearestInfo] = useState<{
    dist: number;
    time: number;
  }>({ dist: 0, time: 0 });
  const [lightModal, setLightModal] = useState<LatLng | null>(null);
  const [cycleModal, setCycleModal] = useState<{ light_id: string } | null>(
    null,
  );
  const [hudInfo, setHudInfo] = useState({
    maneuver: '',
    distance: 0,
    street: '',
    eta: 0,
    speedLimit: 0,
  });
  const [, setSteps] = useState<RouteStep[]>([]);
  const { visible: menuVisible, toggle: toggleMenu, hide: hideMenu } =
    useMenu(false);
  const [themeName, setThemeName] = useState(themeNameValue);
  const [settingsVisible, setSettingsVisible] = useState(false);
  const [logsVisible, setLogsVisible] = useState(false);

  useEffect(() => {
    if (!supabaseError) return;
    loadRoute().then((cached) => {
      if (cached) {
        setRoute(cached.geometry as LatLng[]);
        setSteps(cached.steps as RouteStep[]);
        if (cached.steps.length) {
          const first = cached.steps[0];
          setHudInfo({
            maneuver: first.instruction,
            distance: first.distance,
            street: first.name,
            eta: first.duration,
            speedLimit: first.speed,
          });
        }
      }
    });
  }, [supabaseError]);

  const onStartNavigation = () => {
    startNavigation(analytics.trackEvent);
    hideMenu();
  };

  const onClearRoute = () => {
    const state = clearRoute();
    setRoute(state.route as LatLng[] | null);
    setSteps(state.steps as RouteStep[]);
    setHudInfo(state.hudInfo);
    setLightsOnRoute(state.lightsOnRoute as LightOnRoute[]);
    setRecommended(state.recommended as number);
    setNearestInfo(state.nearestInfo);
    hideMenu();
  };

  const handleAddLight = () => {
    if (car)
      setLightModal({ latitude: car.latitude, longitude: car.longitude });
    hideMenu();
  };

  const handleSettings = () => {
    analytics.trackEvent('settings_change');
    hideMenu();
    setSettingsVisible(true);
  };

  const handleLogs = () => {
    hideMenu();
    setLogsVisible(true);
  };

  useEffect(() => {
    loadTheme().then(() => setThemeName(themeNameValue));
    loadSpeechEnabled();
    loadLeadTimeSec();
  }, []);

  useEffect(() => {
    const t = setInterval(() => setNowSec(Math.floor(Date.now() / 1000)), 1000);
    return () => clearInterval(t);
  }, []);

  useEffect(() => {
    const id = setInterval(() => {
      lights.forEach((l) => {
        void notifyGreenPhase(l.id, leadTimeSec);
      });
    }, 30000);
    return () => clearInterval(id);
  }, [lights]);

  const onUserLocationChange = (e: UserLocationChangeEvent) => {
    const { coordinate } = e.nativeEvent;
    if (!coordinate) return;
    const { latitude, longitude, heading, speed } = coordinate;
    setCar({ latitude, longitude, heading, speed: speed || 0 });
    mapRef.current?.animateCamera({ center: { latitude, longitude } });
  };

  const onMapPress = async (e: MapPressEvent) => {
    if (!car) return;
    const dest = e.nativeEvent.coordinate;
    try {
      const r = await getRoute(car, dest);
      await saveRoute(r);
      setRoute(r.geometry);
      setSteps(r.steps || []);
      if (r.steps && r.steps.length) {
        const first = r.steps[0];
        setHudInfo({
          maneuver: first.instruction,
          distance: first.distance,
          street: first.name,
          eta: first.duration,
          speedLimit: first.speed,
        });
      }
      const projected = projectLightsToRoute(r.geometry, lights, cycles);
      setLightsOnRoute(projected);
    } catch (err) {
      const message = err instanceof Error ? err.message : String(err);
      Alert.alert(i18n.t('error'), message);
    }
  };

  const onLongPress = (e: LongPressEvent) => {
    if (!car) return;
    const dest = e.nativeEvent.coordinate;
    setLightModal(dest);
  };

  const saveLight = async (data: {
    name: string;
    direction: string;
    lat: number;
    lon: number;
  }) => {
    const { data: inserted, error } = await supabase
      .from('lights')
      .insert({
        name: data.name,
        direction: data.direction,
        lat: data.lat,
        lon: data.lon,
      })
      .select()
      .single();
    if (!error) {
      analytics.trackEvent('light_added', { id: inserted.id });
      setLights((l) => [...l, inserted as Light]);
      setLightModal(null);
      setCycleModal({ light_id: inserted.id });
    }
  };

  const saveCycle = async (cycle: LightCycle) => {
    const { data: inserted, error } = await supabase
      .from('light_cycles')
      .insert({ ...cycle, light_id: cycleModal!.light_id })
      .select()
      .single();
    if (!error) {
      setCycles((c) => ({ ...c, [inserted.light_id]: inserted as LightCycle }));
      setCycleModal(null);
    }
  };

  useEffect(() => {
    if (!car) return;
    const { recommended: rec, nearestInfo } = computeRecommendation(
      lightsOnRoute,
      car,
      nowSec,
      recommended,
    );
    setNearestInfo(nearestInfo);
    setRecommended(rec);
  }, [lightsOnRoute, car, nowSec, recommended]);

  return (
    <View
      style={[styles.container, { backgroundColor: colors[themeName].background }]}
    >
      {loadError && <Text testID="load-error">{loadError}</Text>}
      <MapViewWrapper
        mapRef={mapRef}
        car={car}
        lights={lights}
        cycles={cycles}
        nowSec={nowSec}
        route={route}
        lightsOnRoute={lightsOnRoute}
        onMapPress={onMapPress}
        onLongPress={onLongPress}
        onUserLocationChange={onUserLocationChange}
      />
      <SpeedBanner
        speed={recommended}
        nearestDist={nearestInfo.dist}
        timeToWindow={nearestInfo.time}
      />
      <DrivingHUD
        maneuver={hudInfo.maneuver}
        distance={hudInfo.distance}
        street={hudInfo.street}
        eta={hudInfo.eta}
        speed={car ? car.speed * 3.6 : 0}
        speedLimit={hudInfo.speedLimit}
      />
      <MenuContainer
        visible={menuVisible}
        onToggle={toggleMenu}
        onStartNavigation={onStartNavigation}
        onClearRoute={onClearRoute}
        onAddLight={handleAddLight}
        onLogs={handleLogs}
        onSettings={handleSettings}
      />
      {lightModal && (
        <LightFormModal
          visible={true}
          coordinate={lightModal}
          onSubmit={saveLight}
          onCancel={() => setLightModal(null)}
        />
      )}
      {cycleModal && (
        <CycleFormModal
          visible={true}
          onSubmit={saveCycle}
          onCancel={() => setCycleModal(null)}
        />
      )}
      <Settings
        visible={settingsVisible}
        onClose={() => setSettingsVisible(false)}
        onTheme={(t) => setThemeName(t)}
      />
      <LogViewer
        visible={logsVisible}
        onClose={() => setLogsVisible(false)}
      />
    </View>
  );
}

const styles = StyleSheet.create({
  container: { flex: 1 },
});
