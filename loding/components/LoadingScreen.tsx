
import React, { useState, useEffect } from 'react';
import Robot from './Robot';
import Scanner from './Scanner';
import { motion } from 'framer-motion';

interface LoadingScreenProps {
  progress: number;
}

const LoadingScreen: React.FC<LoadingScreenProps> = ({ progress }) => {
  const [dots, setDots] = useState('.');

  useEffect(() => {
    const interval = setInterval(() => {
      setDots((prev) => {
        if (prev === '...') return '.';
        return prev + '.';
      });
    }, 500);
    return () => clearInterval(interval);
  }, []);

  return (
    <div className="flex flex-col items-center justify-between h-full w-full max-w-md py-14 px-8 bg-gradient-to-b from-[#F0F9FF] to-[#E0F2FE]">
      
      {/* Top Section: Branding/Text */}
      <motion.div 
        initial={{ opacity: 0, y: -20 }}
        animate={{ opacity: 1, y: 0 }}
        className="text-center"
      >
        <span className="inline-block px-3 py-1 bg-blue-100 text-blue-600 text-[10px] font-bold rounded-full mb-3 tracking-widest uppercase">
          Scanning Mode
        </span>
        <h2 className="text-3xl font-bold text-slate-800 tracking-tight">안녕하세요!</h2>
        <h1 className="text-2xl font-semibold text-slate-800 mt-1">
          AI 정비사 <span className="text-blue-500">픽시</span>가 도와드릴게요
        </h1>
      </motion.div>

      {/* Middle Section: Main Animation */}
      <div className="relative flex flex-col items-center gap-6 py-6 w-full">
        <Robot isScanning={true} />
        
        <motion.div 
          initial={{ opacity: 0, scale: 0.9 }}
          animate={{ opacity: 1, scale: 1 }}
          className="w-full flex justify-center -mt-4"
        >
          <Scanner progress={progress} />
        </motion.div>

        <div className="text-center space-y-2 mt-2">
          <motion.div
            animate={{ opacity: [1, 0.4, 1] }}
            transition={{ duration: 2, repeat: Infinity, ease: "easeInOut" }}
            className="flex items-center justify-center min-w-[200px]"
          >
            <p className="text-slate-500 text-sm font-medium">
              파손된 부위 사진을 분석하고 있어요<span className="inline-block w-6 text-left">{dots}</span>
            </p>
          </motion.div>
          <div className="flex items-center justify-center gap-2">
             <div className="w-1.5 h-1.5 rounded-full bg-blue-500 animate-ping" />
             <p className="text-blue-600 font-black text-xl tracking-tighter">{Math.round(progress)}%</p>
          </div>
        </div>
      </div>

      {/* Bottom Section: Progress Bar */}
      <div className="w-full space-y-5">
        <div className="relative w-full bg-white/50 backdrop-blur-sm h-3 rounded-full overflow-hidden shadow-inner border border-white">
          <motion.div 
            className="h-full bg-gradient-to-r from-blue-400 via-blue-500 to-indigo-600 shadow-[0_0_10px_rgba(59,130,246,0.5)]"
            initial={{ width: '0%' }}
            animate={{ width: `${progress}%` }}
            transition={{ ease: "linear" }}
          />
          {/* Animated Highlight on bar */}
          <motion.div 
            className="absolute top-0 left-0 h-full w-20 bg-gradient-to-r from-transparent via-white/30 to-transparent"
            animate={{ left: ['-20%', '120%'] }}
            transition={{ duration: 1.5, repeat: Infinity, ease: "linear" }}
          />
        </div>
        
        <p className="text-slate-400 text-[11px] text-center leading-relaxed font-medium">
          픽시가 정밀 스캔을 통해 빠르게 견적을 내어드려요.<br/>
          <span className="text-slate-300">잠시만 기다려 주세요!</span>
        </p>
      </div>

      {/* Background Decorative Blurs */}
      <div className="absolute top-1/3 left-0 -translate-x-1/2 -z-10 blur-[80px] opacity-30">
         <div className="w-48 h-48 bg-blue-400 rounded-full" />
      </div>
      <div className="absolute bottom-1/4 right-0 translate-x-1/2 -z-10 blur-[80px] opacity-20">
         <div className="w-56 h-56 bg-indigo-300 rounded-full" />
      </div>

    </div>
  );
};

export default LoadingScreen;
