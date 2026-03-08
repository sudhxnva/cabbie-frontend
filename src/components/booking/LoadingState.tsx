import React, { useState, useEffect } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { Cpu, Smartphone, Search, Database } from 'lucide-react';

const steps = [
  { text: 'Spinning up Android Emulators...', icon: <Smartphone /> },
  { text: 'Claude Agents navigating Uber & Lyft apps...', icon: <Cpu /> },
  { text: 'Reading screen content via ADB...', icon: <Search /> },
  { text: 'Ranking options based on your constraints...', icon: <Database /> },
];

const LoadingState: React.FC = () => {
  const [currentStep, setCurrentStep] = useState(0);

  useEffect(() => {
    const interval = setInterval(() => {
      setCurrentStep((prev) => (prev + 1) % steps.length);
    }, 15000); // Change text every 15s since total can be 180s
    return () => clearInterval(interval);
  }, []);

  return (
    <div className="loading-container">
      <motion.div 
        animate={{ scale: [1, 1.1, 1] }}
        transition={{ duration: 2, repeat: Infinity }}
        className="main-loader"
      >
        <div className="taxi-icon">🚖</div>
      </motion.div>

      <div className="loading-steps">
        <AnimatePresence mode="wait">
          <motion.div
            key={currentStep}
            initial={{ opacity: 0, y: 10 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: -10 }}
            className="step-item"
          >
            <span className="step-icon">{steps[currentStep].icon}</span>
            <p className="step-text">{steps[currentStep].text}</p>
          </motion.div>
        </AnimatePresence>
      </div>

      <p className="wait-hint">
        Our agents are literally "driving" the apps for you. <br />
        This takes ~2-3 minutes to get real-time price accuracy.
      </p>
    </div>
  );
};

export default LoadingState;
