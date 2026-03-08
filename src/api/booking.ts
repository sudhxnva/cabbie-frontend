import axios from 'axios';
import type { BookingRequest, RankedResult, ConfirmRequest } from '../types/booking';

const API_BASE_URL = import.meta.env.VITE_API_URL || 'http://localhost:3000';

const API = axios.create({
  baseURL: API_BASE_URL,
  timeout: 200000, // 200 seconds — orchestration takes up to 180s
  headers: {
    'Content-Type': 'application/json',
  },
});

export const requestRides = async (data: BookingRequest): Promise<RankedResult[]> => {
  const response = await API.post<RankedResult[]>('/booking/request', data);
  return response.data;
};

export const confirmRide = async (data: ConfirmRequest): Promise<{ status: string; message: string }> => {
  const response = await API.post('/booking/confirm', data);
  return response.data;
};

export default API;
