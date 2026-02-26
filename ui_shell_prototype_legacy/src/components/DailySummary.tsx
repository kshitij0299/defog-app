import { ArrowLeft, CheckCircle, Target, Sparkles } from 'lucide-react';
import { Task, Goal } from '../App';

type DailySummaryProps = {
  tasks: Task[];
  goals: Goal[];
  onBack: () => void;
};

export function DailySummary({ tasks, goals, onBack }: DailySummaryProps) {
  const today = new Date();
  
  // Tasks completed today
  const tasksCompletedToday = tasks.filter(task => {
    if (!task.completedAt) return false;
    return task.completedAt.toDateString() === today.toDateString();
  });

  // Goals updated today
  const goalsUpdatedToday = goals.filter(goal => {
    return goal.entries.some(entry => 
      entry.date.toDateString() === today.toDateString()
    );
  });

  const totalProgress = tasksCompletedToday.length + goalsUpdatedToday.length;

  return (
    <div className="flex flex-col h-full">
      {/* Header */}
      <div className="p-6 border-b border-gray-200">
        <button onClick={onBack} className="mb-4 text-gray-600">
          <ArrowLeft size={24} />
        </button>
        <h1 className="text-gray-900 mb-1">Today's Summary</h1>
        <p className="text-sm text-gray-500">
          {today.toLocaleDateString('en-US', { 
            weekday: 'long', 
            month: 'long', 
            day: 'numeric' 
          })}
        </p>
      </div>

      {/* Content */}
      <div className="flex-1 overflow-auto p-6">
        {totalProgress > 0 ? (
          <div className="space-y-6">
            {/* Celebration */}
            <div className="p-6 bg-gradient-to-br from-purple-50 to-blue-50 border border-purple-200 rounded-lg text-center">
              <Sparkles size={32} className="text-purple-600 mx-auto mb-3" />
              <h2 className="text-gray-900 mb-2">Great work today!</h2>
              <p className="text-gray-600">
                You made progress on {totalProgress} {totalProgress === 1 ? 'thing' : 'things'}
              </p>
            </div>

            {/* Tasks Completed */}
            {tasksCompletedToday.length > 0 && (
              <div>
                <div className="flex items-center gap-2 mb-3">
                  <CheckCircle size={20} className="text-gray-600" />
                  <h3 className="text-gray-900">Tasks Completed</h3>
                </div>
                <div className="space-y-2">
                  {tasksCompletedToday.map(task => (
                    <div
                      key={task.id}
                      className="p-4 bg-white border border-gray-200 rounded-lg"
                    >
                      <p className="text-gray-700">{task.text}</p>
                    </div>
                  ))}
                </div>
              </div>
            )}

            {/* Goals Updated */}
            {goalsUpdatedToday.length > 0 && (
              <div>
                <div className="flex items-center gap-2 mb-3">
                  <Target size={20} className="text-gray-600" />
                  <h3 className="text-gray-900">Goals Updated</h3>
                </div>
                <div className="space-y-2">
                  {goalsUpdatedToday.map(goal => {
                    const todayEntry = goal.entries.find(entry => 
                      entry.date.toDateString() === today.toDateString()
                    );
                    
                    return (
                      <div
                        key={goal.id}
                        className="p-4 bg-white border border-gray-200 rounded-lg"
                      >
                        <div className="flex items-center gap-3 mb-2">
                          <div
                            className="w-3 h-3 rounded-full"
                            style={{ backgroundColor: goal.color }}
                          />
                          <h4 className="text-gray-900">{goal.name}</h4>
                        </div>
                        {todayEntry?.text && (
                          <p className="text-sm text-gray-600 italic">"{todayEntry.text}"</p>
                        )}
                      </div>
                    );
                  })}
                </div>
              </div>
            )}

            {/* Reflection */}
            <div className="p-4 bg-gray-50 border border-gray-200 rounded-lg">
              <p className="text-sm text-gray-600 leading-relaxed">
                Every small step counts. You're building momentum, one day at a time.
              </p>
            </div>
          </div>
        ) : (
          <div className="flex flex-col items-center justify-center h-full text-center">
            <div className="w-16 h-16 bg-gray-100 rounded-full flex items-center justify-center mb-4">
              <Sparkles size={32} className="text-gray-400" />
            </div>
            <h2 className="text-gray-900 mb-2">Start your day</h2>
            <p className="text-gray-500 max-w-xs mb-6">
              No progress logged yet today. What would you like to work on?
            </p>
            <button
              onClick={onBack}
              className="px-6 py-3 bg-gray-900 text-white rounded-lg"
            >
              Back to Home
            </button>
          </div>
        )}
      </div>
    </div>
  );
}
