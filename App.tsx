import React, { useRef, useState, useEffect } from 'react';
import { Alert, StyleSheet, View, Text, TouchableOpacity } from 'react-native';
import MapView, {
  Marker,
  Polyline,
  MapPressEvent,
  LongPressEvent,
  UserLocationChangeEvent,
  LatLng,
} from 'react-native-maps';
import CarMarker from './src/components/CarMarker';
import DrivingHUD from './src/components/DrivingHUD';
import LightFormModal from './src/components/LightFormModal';
import CycleFormModal from './src/components/CycleFormModal';
import SpeedBanner from './src/components/SpeedBanner';
import MainMenu from './src/components/MainMenu';
import { supabaseService, supabase } from './src/services/supabase';
import { getRoute, RouteStep } from './src/services/ors';
import { saveRoute, loadRoute } from './src/services/routeCache';
import i18n from './src/i18n';
import { mapColorForRuntime } from './src/domain/phases';
import { projectLightsToRoute } from './src/domain/matching';
import { analytics } from './src/services/analytics';
import {
  handleStartNavigation as startNavigation,
  handleClearRoute as clearRoute,
  computeRecommendation,
  LightOnRoute,
} from './src';
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
  const [lights, setLights] = useState<Light[]>([]);
  const [cycles, setCycles] = useState<Record<string, LightCycle>>({});
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
  const [loadError, setLoadError] = useState<string | null>(null);
  const [hudInfo, setHudInfo] = useState({
    maneuver: '',
    distance: 0,
    street: '',
    eta: 0,
    speedLimit: 0,
  });
  const [, setSteps] = useState<RouteStep[]>([]);
  const [menuVisible, setMenuVisible] = useState<boolean>(false);

  const onStartNavigation = () => {
    startNavigation(analytics.trackEvent);
    setMenuVisible(false);
  };

  const onClearRoute = () => {
    const state = clearRoute();
    setRoute(state.route as LatLng[] | null);
    setSteps(state.steps as RouteStep[]);
    setHudInfo(state.hudInfo);
    setLightsOnRoute(state.lightsOnRoute as LightOnRoute[]);
    setRecommended(state.recommended as number);
    setNearestInfo(state.nearestInfo);
    setMenuVisible(state.menuVisible);
  };

  const handleAddLight = () => {
    if (car)
      setLightModal({ latitude: car.latitude, longitude: car.longitude });
    setMenuVisible(false);
  };

  const handleSettings = () => {
    analytics.trackEvent('settings_change');
    setMenuVisible(false);
  };

  useEffect(() => {
    supabaseService
      .fetchLightsAndCycles()
      .then(async ({ lights, cycles, error }) => {
        if (error) {
          setLoadError('Failed to load data');
          const cached = await loadRoute();
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
          return;
        }
        setLights(lights);
        const map: Record<string, LightCycle> = {};
        for (const c of cycles) map[c.light_id] = c;
        setCycles(map);
      });
    const sub = supabaseService.subscribeLightCycles((cycle) => {
      setCycles((c) => ({ ...c, [cycle.light_id]: cycle }));
    });
    return () => {
      supabase.removeChannel(sub);
    };
  }, []);

  useEffect(() => {
    const t = setInterval(() => setNowSec(Math.floor(Date.now() / 1000)), 1000);
    return () => clearInterval(t);
  }, []);

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
    <View style={styles.container}>
      {loadError && <Text testID="load-error">{loadError}</Text>}
      <MapView
        ref={mapRef}
        style={styles.map}
        showsUserLocation
        onUserLocationChange={onUserLocationChange}
        onPress={onMapPress}
        onLongPress={onLongPress}
        customMapStyle={nightStyle}
      >
        {car && <CarMarker coordinate={car} heading={car.heading} />}
        {lights.map((l) => {
          const cycle = cycles[l.id] || null;
          const color = mapColorForRuntime(cycle, l.direction, nowSec);
          const isNearest =
            lightsOnRoute.length && lightsOnRoute[0].light.id === l.id;
          return (
            <Marker
              key={l.id}
              coordinate={{ latitude: l.lat, longitude: l.lon }}
              pinColor={isNearest ? 'yellow' : color}
            />
          );
        })}
        {route && (
          <Polyline coordinates={route} strokeColor="yellow" strokeWidth={3} />
        )}
      </MapView>
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
      <MainMenu
        visible={menuVisible}
        onStartNavigation={onStartNavigation}
        onClearRoute={onClearRoute}
        onAddLight={handleAddLight}
        onSettings={handleSettings}
      />
      <TouchableOpacity
        style={styles.fab}
        onPress={() => setMenuVisible((v) => !v)}
        testID="menu-button"
      >
        <Text style={styles.fabText}>☰</Text>
      </TouchableOpacity>
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
    </View>
  );
}

const nightStyle = [
  { elementType: 'geometry', stylers: [{ color: '#212121' }] },
  { elementType: 'labels.icon', stylers: [{ visibility: 'off' }] },
  { elementType: 'labels.text.fill', stylers: [{ color: '#757575' }] },
  { elementType: 'labels.text.stroke', stylers: [{ color: '#212121' }] },
  {
    featureType: 'road',
    elementType: 'geometry',
    stylers: [{ color: '#484848' }],
  },
  {
    featureType: 'water',
    elementType: 'geometry',
    stylers: [{ color: '#000000' }],
  },
];

const FAB_BG = 'rgba(0,0,0,0.8)';
const FAB_TEXT_COLOR = '#fff';

const styles = StyleSheet.create({
  container: { flex: 1 },
  fab: {
    alignItems: 'center',
    backgroundColor: FAB_BG,
    borderRadius: 25,
    bottom: 20,
    height: 50,
    justifyContent: 'center',
    position: 'absolute',
    right: 20,
    width: 50,
  },
  fabText: {
    color: FAB_TEXT_COLOR,
    fontSize: 24,
  },
  map: { flex: 1 },
});
