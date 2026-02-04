
import React from 'react';
import { motion, AnimatePresence } from 'framer-motion';

const CAR_IMAGES = [
  'https://picsum.photos/id/1071/300/200',
  'https://picsum.photos/id/111/300/200',
  'https://picsum.photos/id/183/300/200',
  'https://picsum.photos/id/133/300/200',
  'https://picsum.photos/id/447/300/200',
];

interface ScannerProps {
  progress: number;
}

const Scanner: React.FC<ScannerProps> = ({ progress }) => {
  const activeIndex = Math.floor((progress / 100) * CAR_IMAGES.length) % CAR_IMAGES.length;

  return (
    <div className="relative w-full max-w-xs h-44 flex items-center justify-center overflow-hidden">
      <AnimatePresence mode="wait">
        <motion.div
          key={activeIndex}
          initial={{ opacity: 0, filter: 'blur(10px)', scale: 1.1 }}
          animate={{ opacity: 1, filter: 'blur(0px)', scale: 1 }}
          exit={{ opacity: 0, filter: 'blur(10px)', scale: 0.9 }}
          transition={{ duration: 0.4 }}
          className="relative rounded-2xl overflow-hidden shadow-[0_0_30px_rgba(59,130,246,0.3)] border-2 border-white/80"
        >
          <img 
            src={CAR_IMAGES[activeIndex]} 
            alt="Scanning Car" 
            className="w-52 h-36 object-cover grayscale brightness-90 contrast-110"
          />
          
          {/* HUD Overlay Corners */}
          <div className="absolute inset-0 p-2 pointer-events-none">
            <div className="absolute top-2 left-2 w-3 h-3 border-t-2 border-l-2 border-blue-400" />
            <div className="absolute top-2 right-2 w-3 h-3 border-t-2 border-r-2 border-blue-400" />
            <div className="absolute bottom-2 left-2 w-3 h-3 border-b-2 border-l-2 border-blue-400" />
            <div className="absolute bottom-2 right-2 w-3 h-3 border-b-2 border-r-2 border-blue-400" />
          </div>

          {/* Scanning Beam Overlay */}
          <motion.div 
            className="absolute top-0 left-0 w-full h-full bg-blue-500/10"
            animate={{ opacity: [0.05, 0.2, 0.05] }}
            transition={{ duration: 1.5, repeat: Infinity }}
          />
          
          {/* High-tech Scanning Line */}
          <motion.div
            className="absolute top-0 left-0 w-full h-[2px] bg-blue-400 shadow-[0_0_10px_#60A5FA,0_0_20px_#3B82F6]"
            animate={{ top: ['0%', '100%', '0%'] }}
            transition={{ duration: 1.8, repeat: Infinity, ease: "linear" }}
          />

          {/* AI "Detecting" Marker */}
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: [0, 1, 0], scale: [0.8, 1, 0.8] }}
            transition={{ duration: 2, repeat: Infinity, delay: 0.5 }}
            className="absolute top-1/4 left-1/3 w-6 h-6 border-2 border-red-500/60 rounded-sm"
          />
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: [0, 1, 0], scale: [0.8, 1, 0.8] }}
            transition={{ duration: 2, repeat: Infinity, delay: 1.2 }}
            className="absolute bottom-1/3 right-1/4 w-8 h-8 border-2 border-red-500/60 rounded-sm"
          />
        </motion.div>
      </AnimatePresence>

      {/* Floating Digital Fragments */}
      <div className="absolute inset-0 -z-10 pointer-events-none">
        {[...Array(8)].map((_, i) => (
          <motion.div
            key={i}
            initial={{ opacity: 0, y: 50, x: 0 }}
            animate={{ 
              opacity: [0, 0.6, 0], 
              y: [-20, -100], 
              x: (i % 2 === 0 ? 1 : -1) * (20 + i * 15),
              rotate: 360
            }}
            transition={{ 
              duration: 3 + Math.random() * 2, 
              repeat: Infinity, 
              delay: i * 0.3 
            }}
            className="absolute text-[8px] font-mono text-blue-400/40"
          >
            {Math.random() > 0.5 ? '01' : '10'}
          </motion.div>
        ))}
      </div>
    </div>
  );
};

export default Scanner;
