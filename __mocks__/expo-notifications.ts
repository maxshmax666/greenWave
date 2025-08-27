export const scheduleNotificationAsync = jest.fn().mockResolvedValue('1');
export const requestPermissionsAsync = jest
  .fn()
  .mockResolvedValue({ status: 'granted' });
