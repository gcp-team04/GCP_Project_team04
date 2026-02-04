
import React from 'react';
import { motion } from 'framer-motion';

interface RobotProps {
  isScanning?: boolean;
}

const Robot: React.FC<RobotProps> = ({ isScanning = false }) => {
  return (
    <motion.div
      initial={{ y: 0 }}
      animate={{ y: [-10, 10, -10] }}
      transition={{
        duration: 4,
        repeat: Infinity,
        ease: "easeInOut"
      }}
      className="relative w-48 h-48 flex items-center justify-center"
    >
      {/* Scanning Beam (Laser) */}
      {isScanning && (
        <motion.div
          initial={{ opacity: 0, scaleX: 0 }}
          animate={{ opacity: [0, 0.4, 0.1, 0.4, 0], scaleX: [0.8, 1.2, 0.9, 1.1, 0.8] }}
          transition={{ duration: 2, repeat: Infinity }}
          className="absolute top-[110px] w-[300px] h-[100px] bg-gradient-to-b from-blue-400/40 to-transparent origin-top pointer-events-none"
          style={{ clipPath: 'polygon(20% 0%, 80% 0%, 100% 100%, 0% 100%)' }}
        />
      )}

      {/* Robot Shadow */}
      <motion.div
        animate={{ scale: [1, 1.2, 1], opacity: [0.1, 0.2, 0.1] }}
        transition={{ duration: 4, repeat: Infinity, ease: "easeInOut" }}
        className="absolute bottom-[-10px] w-24 h-4 bg-blue-900/10 rounded-[100%]"
      />

      <svg width="180" height="180" viewBox="0 0 200 200" fill="none" xmlns="http://www.w3.org/2000/svg" className="relative z-10">
        {/* Antenna Stem */}
        <rect x="95" y="35" width="10" height="25" fill="#46B6EF" />
        
        {/* Antenna Tip */}
        <motion.circle
          cx="100"
          cy="30"
          r="8"
          fill="#FF9234"
          animate={{
            filter: isScanning ? ["drop-shadow(0 0 2px #FF9234)", "drop-shadow(0 0 8px #FF9234)", "drop-shadow(0 0 2px #FF9234)"] : "none",
            scale: isScanning ? [1, 1.3, 1] : 1
          }}
          transition={{ duration: 1, repeat: Infinity }}
        />

        {/* Body Main (Blue) */}
        <rect x="40" y="60" width="120" height="100" rx="40" fill="#46B6EF" />
        
        {/* Face Panel (White) */}
        <rect x="55" y="75" width="90" height="70" rx="25" fill="white" />

        {/* Eyes */}
        <motion.g
          animate={{
            scaleY: [1, 1, 0.1, 1, 1],
          }}
          transition={{
            duration: 3,
            repeat: Infinity,
            times: [0, 0.45, 0.5, 0.55, 1]
          }}
        >
          <circle cx="80" cy="105" r="5" fill="#1E293B" />
          <circle cx="120" cy="105" r="5" fill="#1E293B" />
        </motion.g>

        {/* Smile */}
        <path d="M85 125C85 125 92 132 100 132C108 132 115 125 115 125" stroke="#46B6EF" strokeWidth="4" strokeLinecap="round" />
        
        {/* Scanning Lights (Internal) */}
        {isScanning && (
          <motion.rect
            x="55"
            y="75"
            width="90"
            height="2"
            fill="#46B6EF"
            opacity="0.3"
            animate={{ y: [75, 145, 75] }}
            transition={{ duration: 2, repeat: Infinity }}
          />
        )}
      </svg>
    </motion.div>
  );
};

export default Robot;
