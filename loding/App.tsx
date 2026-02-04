
import React, { useState, useEffect } from 'react';
import LoadingScreen from './components/LoadingScreen';

const App: React.FC = () => {
  const [progress, setProgress] = useState(0);
  const [isFinished, setIsFinished] = useState(false);

  useEffect(() => {
    const timer = setInterval(() => {
      setProgress((prev) => {
        if (prev >= 100) {
          clearInterval(timer);
          setTimeout(() => setIsFinished(true), 500);
          return 100;
        }
        // Simulated progress speed
        const jump = Math.random() * 5 + 1;
        return Math.min(prev + jump, 100);
      });
    }, 150);

    return () => clearInterval(timer);
  }, []);

  if (isFinished) {
    return (
      <div className="flex flex-col items-center justify-center min-h-screen bg-blue-50 text-slate-800 p-6 text-center animate-in fade-in duration-700">
        <div className="bg-white p-8 rounded-3xl shadow-xl max-w-sm w-full">
          <h1 className="text-2xl font-bold mb-4 text-blue-600">분석 완료!</h1>
          <p className="text-slate-600 mb-6">픽시가 모든 파손 부위를<br/>성공적으로 확인했습니다.</p>
          <button 
            onClick={() => {
              setIsFinished(false);
              setProgress(0);
            }}
            className="w-full bg-blue-500 hover:bg-blue-600 text-white font-bold py-3 px-6 rounded-2xl transition-all shadow-lg active:scale-95"
          >
            다시 분석하기
          </button>
        </div>
      </div>
    );
  }

  return (
    <div className="h-screen w-full flex items-center justify-center bg-[#F0F9FF]">
      <LoadingScreen progress={progress} />
    </div>
  );
};

export default App;
