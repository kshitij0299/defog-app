import { useState } from 'react';
import { ArrowLeft, Mic, MicOff } from 'lucide-react';

type InputScreenProps = {
  onSubmit: (text: string, isVoice: boolean) => void;
  onBack: () => void;
};

export function InputScreen({ onSubmit, onBack }: InputScreenProps) {
  const [inputText, setInputText] = useState('');
  const [isListening, setIsListening] = useState(false);

  const handleVoiceInput = () => {
    setIsListening(!isListening);
    
    // Simulate voice input
    if (!isListening) {
      setTimeout(() => {
        setInputText('Learn motion design, call mom, buy groceries, work on music production');
        setIsListening(false);
      }, 2000);
    }
  };

  const handleSubmit = () => {
    if (inputText.trim()) {
      onSubmit(inputText, isListening);
      setInputText('');
    }
  };

  return (
    <div className="flex flex-col h-full p-6">
      {/* Header */}
      <div className="mb-8">
        <button 
          onClick={onBack} 
          className="mb-4 p-2 -ml-2 hover:bg-black/5 rounded-xl transition-all active:scale-95"
        >
          <ArrowLeft size={24} className="text-gray-600" strokeWidth={2.5} />
        </button>
        <h1 className="text-gray-900 mb-2">Brain Dump</h1>
        <p className="text-sm text-gray-500">Tell me everything on your mind</p>
      </div>

      {/* Input Area */}
      <div className="flex-1 flex flex-col">
        <textarea
          value={inputText}
          onChange={(e) => setInputText(e.target.value)}
          placeholder="Type or speak what's on your mind..."
          className="flex-1 p-5 glass-strong rounded-3xl resize-none focus:outline-none focus:ring-2 focus:ring-blue-500/50 text-gray-900 placeholder:text-gray-400 shadow-apple"
        />

        {isListening && (
          <div className="mt-4 glass-strong rounded-2xl p-4 border-2 border-red-500/20 bg-red-50/50 shadow-apple">
            <div className="flex items-center gap-3">
              <div className="w-3 h-3 bg-red-500 rounded-full animate-pulse shadow-lg" />
              <p className="text-sm text-red-700">Listening...</p>
            </div>
          </div>
        )}

        <div className="mt-4 glass rounded-2xl p-4 border border-gray-200/50">
          <p className="text-xs text-gray-500 mb-2">Examples:</p>
          <p className="text-xs text-gray-600 italic leading-relaxed">
            "Buy groceries, call dentist, learn motion design, practice guitar"
          </p>
        </div>
      </div>

      {/* Bottom Actions */}
      <div className="flex gap-3 mt-6">
        <button
          onClick={handleVoiceInput}
          className={`w-16 h-16 rounded-2xl flex items-center justify-center transition-all active:scale-95 shadow-apple ${
            isListening 
              ? 'bg-gradient-to-br from-red-500 to-red-600 text-white' 
              : 'glass-strong text-gray-700 hover:bg-white/80'
          }`}
        >
          {isListening ? (
            <MicOff size={26} strokeWidth={2.5} />
          ) : (
            <Mic size={26} strokeWidth={2.5} />
          )}
        </button>

        <button
          onClick={handleSubmit}
          disabled={!inputText.trim()}
          className="flex-1 py-4 bg-gradient-to-br from-gray-900 to-gray-800 text-white rounded-2xl disabled:opacity-30 hover:from-gray-800 hover:to-gray-700 active:scale-[0.98] transition-all shadow-apple-lg"
        >
          Process
        </button>
      </div>
    </div>
  );
}
