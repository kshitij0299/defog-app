import { CheckCircle, XCircle } from 'lucide-react';

type ToastProps = {
  message: string;
  type: 'success' | 'error';
};

export function Toast({ message, type }: ToastProps) {
  return (
    <div className="absolute top-16 left-6 right-6 z-50 animate-in fade-in slide-in-from-top-2">
      <div
        className={`glass-strong shadow-apple-lg rounded-2xl flex items-center gap-3 p-4 ${
          type === 'success' 
            ? 'border-2 border-green-500/20 bg-green-50/90' 
            : 'border-2 border-red-500/20 bg-red-50/90'
        }`}
      >
        {type === 'success' ? (
          <CheckCircle size={22} className="text-green-600" strokeWidth={2.5} />
        ) : (
          <XCircle size={22} className="text-red-600" strokeWidth={2.5} />
        )}
        <span className={type === 'success' ? 'text-green-900' : 'text-red-900'}>
          {message}
        </span>
      </div>
    </div>
  );
}
