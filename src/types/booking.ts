export interface BookingRequest {
  userId: string;
  pickup: { address: string };
  dropoff: { address: string };
  passengers?: number;
  constraints: {
    priority: 'cheapest' | 'fastest' | 'comfortable' | 'luxury' | 'eco' | 'free';
    specificApp?: string;
    maxPrice?: number;
    maxWaitMinutes?: number;
  };
}

export interface RideOption {
  name: string; // "UberX", "Lyft Standard"
  price: string; // keep as string — OCR may return ranges like "$12-14"
  priceMin?: number;
  etaMinutes: number;
  category: 'standard' | 'comfort' | 'xl' | 'luxury' | 'eco' | 'free';
}

export interface RankedResult extends RideOption {
  appName: string;
}

export interface ConfirmRequest {
  sessionId: string;
  option: RankedResult;
}
