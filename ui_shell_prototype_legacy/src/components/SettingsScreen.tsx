import { ArrowLeft, BarChart3, Archive, Info, Moon, Bell } from 'lucide-react';

type SettingsScreenProps = {
  onBack: () => void;
  onNavigate: (screen: string) => void;
  isDarkMode: boolean;
  onToggleDarkMode: () => void;
};

export function SettingsScreen({ onBack, onNavigate, isDarkMode, onToggleDarkMode }: SettingsScreenProps) {
  return (
    <div className="flex flex-col h-full">
      {/* Header */}
      <div className={`p-6 border-b ${isDarkMode ? 'border-gray-700/50' : 'border-gray-200'}`}>
        <button onClick={onBack} className={`mb-4 ${isDarkMode ? 'text-gray-400' : 'text-gray-600'}`}>
          <ArrowLeft size={24} />
        </button>
        <h1 className={isDarkMode ? 'text-gray-100' : 'text-gray-900'}>Settings</h1>
      </div>

      {/* Settings List */}
      <div className="flex-1 overflow-auto p-6">
        <div className="space-y-6">
          {/* Insights */}
          <div>
            <h3 className={`text-sm mb-3 ${isDarkMode ? 'text-gray-400' : 'text-gray-500'}`}>Your Progress</h3>
            <button
              onClick={() => onNavigate('insights')}
              className={`w-full flex items-center gap-4 p-4 ${isDarkMode ? 'bg-gray-800/50 border-gray-700/50 hover:border-gray-600' : 'bg-white border-gray-200 hover:border-gray-300'} border rounded-lg transition-colors`}
            >
              <BarChart3 size={24} className={isDarkMode ? 'text-gray-400' : 'text-gray-600'} />
              <div className="flex-1 text-left">
                <h4 className={isDarkMode ? 'text-gray-100' : 'text-gray-900'}>Insights</h4>
                <p className={`text-sm ${isDarkMode ? 'text-gray-400' : 'text-gray-500'}`}>View your progress and stats</p>
              </div>
            </button>
          </div>

          {/* History */}
          <div>
            <h3 className={`text-sm mb-3 ${isDarkMode ? 'text-gray-400' : 'text-gray-500'}`}>Data</h3>
            <button
              onClick={() => onNavigate('history')}
              className={`w-full flex items-center gap-4 p-4 ${isDarkMode ? 'bg-gray-800/50 border-gray-700/50 hover:border-gray-600' : 'bg-white border-gray-200 hover:border-gray-300'} border rounded-lg transition-colors`}
            >
              <Archive size={24} className={isDarkMode ? 'text-gray-400' : 'text-gray-600'} />
              <div className="flex-1 text-left">
                <h4 className={isDarkMode ? 'text-gray-100' : 'text-gray-900'}>History</h4>
                <p className={`text-sm ${isDarkMode ? 'text-gray-400' : 'text-gray-500'}`}>View completed tasks</p>
              </div>
            </button>
          </div>

          {/* Preferences */}
          <div>
            <h3 className={`text-sm mb-3 ${isDarkMode ? 'text-gray-400' : 'text-gray-500'}`}>Preferences</h3>
            <div className="space-y-2">
              <div className={`flex items-center justify-between p-4 ${isDarkMode ? 'bg-gray-800/50 border-gray-700/50' : 'bg-white border-gray-200'} border rounded-lg`}>
                <div className="flex items-center gap-4">
                  <Bell size={24} className={isDarkMode ? 'text-gray-400' : 'text-gray-600'} />
                  <div>
                    <h4 className={isDarkMode ? 'text-gray-100' : 'text-gray-900'}>Gentle Reminders</h4>
                    <p className={`text-sm ${isDarkMode ? 'text-gray-400' : 'text-gray-500'}`}>Daily check-in nudges</p>
                  </div>
                </div>
                <label className="relative inline-block w-12 h-6">
                  <input type="checkbox" className="sr-only peer" defaultChecked />
                  <div className={`w-full h-full ${isDarkMode ? 'bg-gray-700 peer-checked:bg-blue-600' : 'bg-gray-300 peer-checked:bg-gray-900'} rounded-full peer-focus:outline-none transition-colors`}></div>
                  <div className="absolute left-1 top-1 bg-white w-4 h-4 rounded-full peer-checked:translate-x-6 transition-transform"></div>
                </label>
              </div>

              <div className={`flex items-center justify-between p-4 ${isDarkMode ? 'bg-gray-800/50 border-gray-700/50' : 'bg-white border-gray-200'} border rounded-lg`}>
                <div className="flex items-center gap-4">
                  <Moon size={24} className={isDarkMode ? 'text-gray-400' : 'text-gray-600'} />
                  <div>
                    <h4 className={isDarkMode ? 'text-gray-100' : 'text-gray-900'}>Dark Mode</h4>
                    <p className={`text-sm ${isDarkMode ? 'text-gray-400' : 'text-gray-500'}`}>Easy on the eyes</p>
                  </div>
                </div>
                <label className="relative inline-block w-12 h-6 cursor-pointer">
                  <input 
                    type="checkbox" 
                    className="sr-only peer" 
                    checked={isDarkMode}
                    onChange={onToggleDarkMode}
                  />
                  <div className={`w-full h-full ${isDarkMode ? 'bg-blue-600' : 'bg-gray-300'} rounded-full peer-focus:outline-none transition-colors`}></div>
                  <div className="absolute left-1 top-1 bg-white w-4 h-4 rounded-full peer-checked:translate-x-6 transition-transform"></div>
                </label>
              </div>
            </div>
          </div>

          {/* About */}
          <div>
            <h3 className={`text-sm mb-3 ${isDarkMode ? 'text-gray-400' : 'text-gray-500'}`}>About</h3>
            <div className={`p-4 ${isDarkMode ? 'bg-gray-800/50 border-gray-700/50' : 'bg-white border-gray-200'} border rounded-lg`}>
              <div className="flex items-start gap-4 mb-4">
                <Info size={24} className={isDarkMode ? 'text-gray-400' : 'text-gray-600'} />
                <div>
                  <h4 className={`mb-2 ${isDarkMode ? 'text-gray-100' : 'text-gray-900'}`}>Defog v1.0</h4>
                  <p className={`text-sm leading-relaxed ${isDarkMode ? 'text-gray-400' : 'text-gray-500'}`}>
                    A gentle tool for creative minds to clear mental clutter. 
                    No rigid productivity systems, just clarity.
                  </p>
                </div>
              </div>
              <div className={`pt-4 border-t space-y-2 text-sm ${isDarkMode ? 'border-gray-700/50 text-gray-400' : 'border-gray-200 text-gray-500'}`}>
                <button className={`block ${isDarkMode ? 'hover:text-gray-200' : 'hover:text-gray-900'}`}>Privacy Policy</button>
                <button className={`block ${isDarkMode ? 'hover:text-gray-200' : 'hover:text-gray-900'}`}>Terms of Service</button>
                <button className={`block ${isDarkMode ? 'hover:text-gray-200' : 'hover:text-gray-900'}`}>Send Feedback</button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
