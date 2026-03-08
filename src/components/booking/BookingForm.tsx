import React, { useState } from 'react';
import { MapPin, Navigation, Send } from 'lucide-react';
import type { BookingRequest } from '../../types/booking';

interface BookingFormProps {
  onSubmit: (request: BookingRequest) => void;
  isLoading: boolean;
}

const BookingForm: React.FC<BookingFormProps> = ({ onSubmit, isLoading }) => {
  const [pickup, setPickup] = useState('');
  const [dropoff, setDropoff] = useState('');
  const [priority, setPriority] = useState<BookingRequest['constraints']['priority']>('cheapest');

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!pickup || !dropoff) return;

    onSubmit({
      userId: 'demo-user', // Hardcoded for demo
      pickup: { address: pickup },
      dropoff: { address: dropoff },
      constraints: { priority },
    });
  };

  return (
    <form onSubmit={handleSubmit} className="booking-form">
      <div className="input-group">
        <label>
          <MapPin size={18} />
          Pickup Location
        </label>
        <input
          type="text"
          value={pickup}
          onChange={(e) => setPickup(e.target.value)}
          placeholder="e.g., 1800 Williams St, Denver, CO"
          required
          disabled={isLoading}
        />
      </div>

      <div className="input-group">
        <label>
          <Navigation size={18} />
          Dropoff Location
        </label>
        <input
          type="text"
          value={dropoff}
          onChange={(e) => setDropoff(e.target.value)}
          placeholder="e.g., Denver International Airport"
          required
          disabled={isLoading}
        />
      </div>

      <div className="input-group">
        <label>Priority Constraint</label>
        <select 
          value={priority} 
          onChange={(e) => setPriority(e.target.value as any)}
          disabled={isLoading}
        >
          <option value="cheapest">Cheapest Price</option>
          <option value="fastest">Fastest (Low ETA)</option>
          <option value="comfortable">Comfortable</option>
          <option value="luxury">Luxury / Premium</option>
        </select>
      </div>

      <button type="submit" className="submit-btn" disabled={isLoading || !pickup || !dropoff}>
        {isLoading ? 'Agents Dispatching...' : 'Find Best Rides'}
        <Send size={18} />
      </button>
    </form>
  );
};

export default BookingForm;
