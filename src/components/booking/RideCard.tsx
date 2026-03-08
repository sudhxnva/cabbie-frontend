import React from 'react';
import { Clock, DollarSign, ExternalLink } from 'lucide-react';
import { RankedResult } from '../../types/booking';

interface RideCardProps {
  result: RankedResult;
  onBook: (result: RankedResult) => void;
  isBest: boolean;
}

const RideCard: React.FC<RideCardProps> = ({ result, onBook, isBest }) => {
  const isUber = result.appName.toLowerCase().includes('uber');
  const appColor = isUber ? '#000000' : '#FF00BF'; // Uber Black vs Lyft Pink

  return (
    <div className={`ride-card ${isBest ? 'best-option' : ''}`}>
      {isBest && <div className="badge">BEST MATCH</div>}
      
      <div className="card-header">
        <div className="app-info">
          <span className="app-logo" style={{ backgroundColor: appColor }}>
            {result.appName[0]}
          </span>
          <h3>{result.appName}</h3>
        </div>
        <div className="price-tag">
          {result.price}
        </div>
      </div>

      <div className="card-details">
        <div className="detail-item">
          <span className="label">{result.name}</span>
          <span className="category-tag">{result.category}</span>
        </div>
        
        <div className="stats">
          <div className="stat">
            <Clock size={16} />
            <span>{result.etaMinutes} min away</span>
          </div>
          <div className="stat">
            <DollarSign size={16} />
            <span>OCR Validated</span>
          </div>
        </div>
      </div>

      <button onClick={() => onBook(result)} className="book-btn">
        Book this Ride <ExternalLink size={16} />
      </button>
    </div>
  );
};

export default RideCard;
