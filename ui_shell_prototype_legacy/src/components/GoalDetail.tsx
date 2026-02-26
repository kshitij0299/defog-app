import { useState } from 'react';
import { Goal } from '../App';
import { ArrowLeft, Check, MoreVertical, Edit2, Trash2, Sparkles, MessageSquarePlus } from 'lucide-react';

type GoalDetailProps = {
  goal: Goal;
  onBack: () => void;
  onAddEntry: (goalId: string, text?: string) => void;
  onEdit: () => void;
  onDelete: (goalId: string) => void;
};

export function GoalDetail({ goal, onBack, onAddEntry, onEdit, onDelete }: GoalDetailProps) {
  const [view, setView] = useState<'timeline' | 'calendar'>('timeline');
  const [inputText, setInputText] = useState('');
  const [isAddingEntry, setIsAddingEntry] = useState(false);
  const [showMenu, setShowMenu] = useState(false);
  const [showAIOverview, setShowAIOverview] = useState(false);

  const handleQuickEntry = () => {
    onAddEntry(goal.id);
    setIsAddingEntry(false);
  };

  const handleTextEntry = () => {
    if (inputText.trim()) {
      onAddEntry(goal.id, inputText.trim());
      setInputText('');
      setIsAddingEntry(false);
    }
  };

  const sortedEntries = [...goal.entries].sort((a, b) => b.date.getTime() - a.date.getTime());

  const getDateLabel = (date: Date) => {
    const today = new Date();
    const yesterday = new Date(today);
    yesterday.setDate(yesterday.getDate() - 1);

    if (date.toDateString() === today.toDateString()) {
      return 'Today';
    } else if (date.toDateString() === yesterday.toDateString()) {
      return 'Yesterday';
    } else {
      const daysAgo = Math.floor((today.getTime() - date.getTime()) / (1000 * 60 * 60 * 24));
      return `${daysAgo} days ago`;
    }
  };

  return (
    <div className="flex flex-col h-full">
      {/* Header */}
      <div className="p-6 border-b border-white/30 backdrop-blur-xl bg-white/40">
        <div className="flex items-center justify-between mb-4">
          <button onClick={onBack} className="p-2 -ml-2 hover:bg-black/5 rounded-xl transition-all active:scale-95">
            <ArrowLeft size={24} strokeWidth={2.5} className="text-gray-700" />
          </button>
          <div className="relative">
            <button 
              onClick={() => setShowMenu(!showMenu)}
              className="p-2 hover:bg-black/5 rounded-xl transition-all active:scale-95"
            >
              <MoreVertical size={22} className="text-gray-600" strokeWidth={2.5} />
            </button>

            {showMenu && (
              <div className="absolute right-0 top-12 glass-strong shadow-apple-lg rounded-2xl overflow-hidden z-10 min-w-[160px]">
                <button
                  onClick={() => {
                    onEdit();
                    setShowMenu(false);
                  }}
                  className="w-full flex items-center gap-3 px-4 py-3 hover:bg-black/5 transition-colors text-left"
                >
                  <Edit2 size={18} className="text-gray-600" strokeWidth={2.5} />
                  <span className="text-sm text-gray-900">Edit Goal</span>
                </button>
                <div className="h-px bg-gray-200/50" />
                <button
                  onClick={() => {
                    if (confirm('Are you sure you want to delete this goal?')) {
                      onDelete(goal.id);
                    }
                    setShowMenu(false);
                  }}
                  className="w-full flex items-center gap-3 px-4 py-3 hover:bg-red-50 transition-colors text-left"
                >
                  <Trash2 size={18} className="text-red-600" strokeWidth={2.5} />
                  <span className="text-sm text-red-600">Delete Goal</span>
                </button>
              </div>
            )}
          </div>
        </div>
        
        <div className="flex items-center gap-3 mb-4">
          <div
            className="w-6 h-6 rounded-full shadow-sm"
            style={{ backgroundColor: goal.color }}
          />
          <h1 className="text-gray-900">{goal.name}</h1>
        </div>

        <div className="flex gap-2">
          <button
            onClick={() => setView('timeline')}
            className={`px-5 py-2.5 rounded-xl text-sm transition-all active:scale-95 ${
              view === 'timeline' 
                ? 'bg-gray-900 text-white shadow-apple' 
                : 'bg-white/60 text-gray-600 hover:bg-white/80'
            }`}
          >
            Timeline
          </button>
          <button
            onClick={() => setView('calendar')}
            className={`px-5 py-2.5 rounded-xl text-sm transition-all active:scale-95 ${
              view === 'calendar' 
                ? 'bg-gray-900 text-white shadow-apple' 
                : 'bg-white/60 text-gray-600 hover:bg-white/80'
            }`}
          >
            Calendar
          </button>
        </div>
      </div>

      {/* Content */}
      <div className="flex-1 overflow-auto p-6">
        {view === 'timeline' ? (
          <div className="space-y-4">
            {sortedEntries.length > 0 ? (
              sortedEntries.map(entry => (
                <div key={entry.id} className="border-l-[3px] border-gray-200 pl-5 pb-4">
                  <div className="flex items-center gap-2 mb-2">
                    <div
                      className="w-3.5 h-3.5 rounded-full border-[3px] border-white shadow-sm"
                      style={{ backgroundColor: goal.color, marginLeft: '-27px' }}
                    />
                    <span className="text-sm text-gray-500">
                      {getDateLabel(entry.date)}
                    </span>
                  </div>
                  
                  {entry.text ? (
                    <div className="glass-strong rounded-xl p-4 shadow-apple">
                      <p className="text-gray-800 leading-relaxed">{entry.text}</p>
                    </div>
                  ) : (
                    <div className="flex items-center gap-2 text-gray-500 italic pl-1">
                      <Check size={16} strokeWidth={2.5} />
                      <span className="text-sm">Did something</span>
                    </div>
                  )}
                </div>
              ))
            ) : (
              <div className="glass rounded-2xl p-12 text-center border border-gray-200/50">
                <p className="text-gray-400">No entries yet</p>
                <p className="text-xs text-gray-400 mt-2">Start tracking your progress</p>
              </div>
            )}
          </div>
        ) : (
          <div>
            {/* Calendar View */}
            <div className="mb-4">
              <div className="grid grid-cols-7 gap-2 mb-3">
                {['S', 'M', 'T', 'W', 'T', 'F', 'S'].map((day, i) => (
                  <div key={i} className="text-center text-xs text-gray-500 p-2 tracking-wide">
                    {day}
                  </div>
                ))}
              </div>
              
              <div className="grid grid-cols-7 gap-2">
                {[...Array(35)].map((_, i) => {
                  const date = new Date();
                  date.setDate(date.getDate() - 34 + i);
                  const hasEntry = goal.entries.some(entry => 
                    entry.date.toDateString() === date.toDateString()
                  );
                  const isToday = date.toDateString() === new Date().toDateString();

                  return (
                    <div
                      key={i}
                      className={`aspect-square rounded-xl flex items-center justify-center text-sm transition-all ${
                        hasEntry 
                          ? 'bg-gray-900 text-white shadow-apple' 
                          : isToday
                          ? 'border-2 border-blue-500 text-blue-600 bg-blue-50/50'
                          : 'glass text-gray-400'
                      }`}
                    >
                      {date.getDate()}
                    </div>
                  );
                })}
              </div>
            </div>

            <div className="mt-6 glass-strong rounded-xl p-4 shadow-apple">
              <div className="flex items-center gap-2">
                <div className="w-4 h-4 bg-gray-900 rounded-md" />
                <p className="text-xs text-gray-600">Days with entries</p>
              </div>
            </div>
          </div>
        )}
      </div>

      {/* Bottom Input Area */}
      <div className="p-6 border-t border-white/30 backdrop-blur-xl bg-white/40">
        {isAddingEntry ? (
          <div className="space-y-3">
            <textarea
              value={inputText}
              onChange={(e) => setInputText(e.target.value)}
              placeholder="What did you do today?"
              className="w-full p-4 glass-strong rounded-2xl resize-none focus:outline-none focus:ring-2 focus:ring-blue-500/50 text-gray-900 placeholder:text-gray-400"
              rows={3}
              autoFocus
            />
            <div className="flex gap-2">
              <button
                onClick={handleTextEntry}
                disabled={!inputText.trim()}
                className="flex-1 py-3.5 bg-gray-900 text-white rounded-2xl disabled:opacity-40 hover:bg-gray-800 active:scale-[0.98] transition-all shadow-apple"
              >
                Add Entry
              </button>
              <button
                onClick={() => setIsAddingEntry(false)}
                className="px-6 py-3.5 glass-strong rounded-2xl hover:bg-white/80 active:scale-[0.98] transition-all text-gray-700"
              >
                Cancel
              </button>
            </div>
          </div>
        ) : (
          <div className="flex gap-2">
            <button
              onClick={handleQuickEntry}
              className="flex-1 py-4 bg-gradient-to-br from-green-500 to-green-600 text-white rounded-2xl flex items-center justify-center gap-2 hover:from-green-600 hover:to-green-700 active:scale-[0.98] transition-all shadow-apple-lg"
            >
              <Check size={22} strokeWidth={2.5} />
              <span>Did something today</span>
            </button>
            <button
              onClick={() => setIsAddingEntry(true)}
              className="p-4 glass-strong rounded-2xl hover:bg-white/80 active:scale-95 transition-all shadow-apple"
            >
              <MessageSquarePlus size={22} className="text-gray-900" strokeWidth={2.5} />
            </button>
          </div>
        )}
      </div>

      {/* AI Overview Button */}
      {!isAddingEntry && (
        <button
          onClick={() => setShowAIOverview(!showAIOverview)}
          className="absolute bottom-32 right-6 w-14 h-14 bg-gradient-to-br from-purple-500 to-purple-600 text-white rounded-2xl flex items-center justify-center shadow-apple-lg hover:scale-105 active:scale-95 transition-transform"
        >
          <Sparkles size={24} strokeWidth={2.5} />
        </button>
      )}

      {/* AI Overview Modal */}
      {showAIOverview && (
        <div className="absolute inset-0 bg-black/40 backdrop-blur-sm flex items-end z-50">
          <div className="glass-strong w-full max-h-[80%] overflow-auto rounded-t-[2rem] border-t border-white/30 shadow-apple-lg">
            <div className="p-6 border-b border-white/30">
              <div className="flex items-center justify-between mb-2">
                <div className="flex items-center gap-2">
                  <Sparkles size={22} className="text-purple-600" strokeWidth={2.5} />
                  <h2 className="text-gray-900">AI Overview</h2>
                </div>
                <button 
                  onClick={() => setShowAIOverview(false)} 
                  className="p-2 hover:bg-black/5 rounded-xl transition-all active:scale-95"
                >
                  <ArrowLeft size={24} className="text-gray-500" strokeWidth={2.5} />
                </button>
              </div>
              <p className="text-sm text-gray-500">Insights about your progress</p>
            </div>

            <div className="p-6 space-y-4">
              {/* Activity Pattern */}
              <div className="glass-strong rounded-2xl p-5 border border-purple-200/50 bg-purple-50/40">
                <h3 className="text-gray-900 mb-2">Activity Pattern</h3>
                <p className="text-sm text-gray-600 leading-relaxed">
                  You've been consistently working on {goal.name} with {goal.entries.length} entries logged. 
                  Your most recent activity was {sortedEntries[0] ? getDateLabel(sortedEntries[0].date).toLowerCase() : 'a while ago'}.
                </p>
              </div>

              {/* Streak */}
              <div className="glass-strong rounded-2xl p-5 border border-green-200/50 bg-green-50/40">
                <h3 className="text-gray-900 mb-2">Momentum</h3>
                <p className="text-sm text-gray-600 leading-relaxed">
                  {goal.entries.length > 0 
                    ? `Great job! You've logged ${goal.entries.length} ${goal.entries.length === 1 ? 'entry' : 'entries'}. Keep building this habit.`
                    : 'Start logging your progress to build momentum.'}
                </p>
              </div>

              {/* Suggestions */}
              <div className="glass-strong rounded-2xl p-5 border border-blue-200/50 bg-blue-50/40">
                <h3 className="text-gray-900 mb-2">Suggestions</h3>
                <ul className="text-sm text-gray-600 space-y-2 leading-relaxed">
                  <li>• Try to log something every day, even small progress counts</li>
                  <li>• Add details to your entries to track what works best</li>
                  <li>• Review your timeline weekly to see patterns</li>
                </ul>
              </div>

              {/* Recent Highlights */}
              {sortedEntries.filter(e => e.text).length > 0 && (
                <div className="glass-strong rounded-2xl p-5 border border-gray-200/50">
                  <h3 className="text-gray-900 mb-3">Recent Highlights</h3>
                  <div className="space-y-3">
                    {sortedEntries
                      .filter(e => e.text)
                      .slice(0, 3)
                      .map(entry => (
                        <div key={entry.id} className="pb-3 border-b border-gray-200/50 last:border-0 last:pb-0">
                          <p className="text-xs text-gray-500 mb-1">{getDateLabel(entry.date)}</p>
                          <p className="text-sm text-gray-700 italic leading-relaxed">"{entry.text}"</p>
                        </div>
                      ))}
                  </div>
                </div>
              )}
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
