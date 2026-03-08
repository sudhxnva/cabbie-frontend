import { useState } from 'react';
import { requestRides, confirmRide } from './api/booking';
import { BookingRequest, RankedResult } from './types/booking';
import BookingForm from './components/booking/BookingForm';
import LoadingState from './components/booking/LoadingState';
import RideCard from './components/booking/RideCard';
import { Car, RefreshCw } from 'lucide-react';
import './App.css';

function App() {
  const [loading, setLoading] = useState(false);
  const [results, setResults] = useState<RankedResult[]>([]);
  const [error, setError] = useState<string | null>(null);
  const [bookingStatus, setBookingStatus] = useState<string | null>(null);

  const handleSearch = async (request: BookingRequest) => {
    setLoading(true);
    setError(null);
    setResults([]);
    setBookingStatus(null);

    try {
      const data = await requestRides(request);
      setResults(data);
      if (data.length === 0) {
        setError('No rides found for your request.');
      }
    } catch (err: any) {
      console.error(err);
      setError(err.response?.data?.message || 'Orchestration timed out. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  const handleBook = async (option: RankedResult) => {
    try {
      const res = await confirmRide({ sessionId: 'demo-session', option });
      setBookingStatus(res.message);
    } catch (err) {
      setBookingStatus('Failed to confirm booking.');
    }
  };

  const reset = () => {
    setResults([]);
    setError(null);
    setBookingStatus(null);
  };

  return (
    <div className="app-container">
      <header>
        <div className="logo">
          <Car size={32} />
          <h1>Cabbie</h1>
        </div>
        <p className="subtitle">Agentic Cab Price Comparison</p>
      </header>

      <main>
        {!loading && results.length === 0 && !bookingStatus && (
          <div className="form-section">
            <BookingForm onSubmit={handleSearch} isLoading={loading} />
          </div>
        )}

        {loading && <LoadingState />}

        {error && (
          <div className="error-card">
            <p>{error}</p>
            <button onClick={reset} className="retry-btn">
              <RefreshCw size={18} /> Try Again
            </button>
          </div>
        )}

        {bookingStatus && (
          <div className="success-card">
            <h2>🎉 Booking Initiated!</h2>
            <p>{bookingStatus}</p>
            <button onClick={reset} className="retry-btn">Back to Search</button>
          </div>
        )}

        {results.length > 0 && !loading && !bookingStatus && (
          <div className="results-section">
            <div className="results-header">
              <h2>Ranked Options</h2>
              <button onClick={reset} className="change-btn">Change Search</button>
            </div>
            <div className="results-grid">
              {results.map((r, i) => (
                <RideCard 
                  key={`${r.appName}-${i}`} 
                  result={r} 
                  onBook={handleBook} 
                  isBest={i === 0} 
                />
              ))}
            </div>
          </div>
        )}
      </main>

      <footer>
        <p>© 2026 Cabbie — Powered by Claude Agents</p>
      </footer>
    </div>
  );
}

export default App;
