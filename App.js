import React, { useRef, useState, useEffect } from 'react';
import { StyleSheet, View } from 'react-native';
import MapView, { Marker, Polyline } from 'react-native-maps';
import CarMarker from './components/CarMarker';
import DrivingHUD from './components/DrivingHUD';
import LightFormModal from './components/LightFormModal';
import CycleFormModal from './components/CycleFormModal';
import SpeedBanner from './components/SpeedBanner';
import { fetchLightsAndCycles, subscribeLightCycles, supabase } from './services/supabase';
import { getRoute } from './services/ors';
import { mapColorForRuntime, getGreenWindow } from './src/domain/phases';
import { projectLightsToRoute } from './src/domain/matching';
import { pickSpeed, applyHysteresis } from './src/domain/advisor';

export default function App() {
  const mapRef = useRef(null);
  const [car, setCar] = useState(null);
  const [lights, setLights] = useState([]);
  const [cycles, setCycles] = useState({});
  const [nowSec, setNowSec] = useState(Math.floor(Date.now() / 1000));
  const [route, setRoute] = useState(null);
  const [lightsOnRoute, setLightsOnRoute] = useState([]);
  const [recommended, setRecommended] = useState(0);
  const [nearestInfo, setNearestInfo] = useState({ dist: 0, time: 0 });
  const [lightModal, setLightModal] = useState(null);
  const [cycleModal, setCycleModal] = useState(null);

  useEffect(() => {
    fetchLightsAndCycles().then(({ lights, cycles }) => {
      setLights(lights);
      const map = {};
      for (const c of cycles) map[c.light_id] = c;
      setCycles(map);
    });
    const sub = subscribeLightCycles(cycle => {
      setCycles(c => ({ ...c, [cycle.light_id]: cycle }));
    });
    return () => {
      supabase.removeChannel(sub);
    };
  }, []);

  useEffect(() => {
    const t = setInterval(() => setNowSec(Math.floor(Date.now() / 1000)), 1000);
    return () => clearInterval(t);
  }, []);

  const onUserLocationChange = e => {
    const { coordinate } = e.nativeEvent;
    const { latitude, longitude, heading, speed } = coordinate;
    setCar({ latitude, longitude, heading, speed: speed || 0 });
    mapRef.current?.animateCamera({ center: { latitude, longitude } });
  };

  const onMapPress = async e => {
    if (!car) return;
    const dest = e.nativeEvent.coordinate;
    const r = await getRoute(car, dest);
    setRoute(r.geometry);
    const legs = [
      {
        distance_m: r.distance,
        duration_s: r.duration,
        coords: r.geometry.map(p => [p.latitude, p.longitude])
      }
    ];
    const proj = projectLightsToRoute(lights, legs);
    const arr = proj.map(p => ({
      light: p.light,
      cycle: cycles[p.light.id] || null,
      dist_m: p.order_m,
      dirForDriver: p.light.direction
    }));
    setLightsOnRoute(arr);
  };

  const onLongPress = e => {
    setLightModal(e.nativeEvent.coordinate);
  };

  const saveLight = async data => {
    const { data: inserted, error } = await supabase
      .from('lights')
      .insert({ name: data.name, direction: data.direction, lat: data.lat, lon: data.lon })
      .select()
      .single();
    if (!error) {
      setLights(l => [...l, inserted]);
      setLightModal(null);
      setCycleModal({ light_id: inserted.id });
    }
  };

  const saveCycle = async cycle => {
    const { data: inserted, error } = await supabase
      .from('light_cycles')
      .insert({ ...cycle, light_id: cycleModal.light_id })
      .select()
      .single();
    if (!error) {
      setCycles(c => ({ ...c, [inserted.light_id]: inserted }));
      setCycleModal(null);
    }
  };

  useEffect(() => {
    if (!car) return;
    const res = pickSpeed(nowSec, lightsOnRoute, car.speed * 3.6);
    const nearest = lightsOnRoute[0];
    let nearestStillGreen = false;
    if (nearest && nearest.cycle) {
      const cycleLen = nearest.cycle.cycle_seconds;
      const t0 = Date.parse(nearest.cycle.t0_iso) / 1000;
      const eta = nowSec + nearest.dist_m / (res.recommended * 1000 / 3600);
      const phase = ((eta - t0) % cycleLen + cycleLen) % cycleLen;
      const [gs, ge] = getGreenWindow(nearest.cycle, nearest.dirForDriver);
      nearestStillGreen = phase >= gs + 2 && phase <= ge - 2;
      let timeToWindow = 0;
      if (phase < gs) timeToWindow = gs - phase;
      else if (phase > ge) timeToWindow = cycleLen - phase + gs;
      setNearestInfo({ dist: nearest.dist_m, time: timeToWindow });
    } else {
      setNearestInfo({ dist: 0, time: 0 });
    }
    setRecommended(prev =>
      prev ? applyHysteresis(prev, res.recommended, nearestStillGreen) : res.recommended
    );
  }, [lightsOnRoute, car, nowSec]);

  return (
    <View style={styles.container}>
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
        {lights.map(l => {
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
      <DrivingHUD />
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
    stylers: [{ color: '#484848' }]
  },
  {
    featureType: 'water',
    elementType: 'geometry',
    stylers: [{ color: '#000000' }]
  }
];

const styles = StyleSheet.create({
  container: { flex: 1 },
  map: { flex: 1 }
});
