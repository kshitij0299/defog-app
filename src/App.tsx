import { useState } from 'react';
import { Home } from './components/Home';
import { TasksView } from './components/TasksView';
import { GoalsView } from './components/GoalsView';
import { GoalDetail } from './components/GoalDetail';
import { InputScreen } from './components/InputScreen';
import { ProcessingScreen } from './components/ProcessingScreen';
import { ConfirmationScreen } from './components/ConfirmationScreen';
import { SettingsScreen } from './components/SettingsScreen';
import { InsightsScreen } from './components/InsightsScreen';
import { HistoryScreen } from './components/HistoryScreen';
import { OnboardingScreen } from './components/OnboardingScreen';
import { DailySummary } from './components/DailySummary';
import { Toast } from './components/Toast';
import { EditGoalModal } from './components/EditGoalModal';
import { Home as HomeIcon, CheckSquare, Target, Plus } from 'lucide-react';

export type Task = {
  id: string;
  text: string;
  completed: boolean;
  createdAt: Date;
  completedAt?: Date;
};

export type GoalEntry = {
  id: string;
  date: Date;
  text?: string;
  didSomething: boolean;
};

export type Goal = {
  id: string;
  name: string;
  color: string;
  entries: GoalEntry[];
  createdAt: Date;
};

type Screen = 'home' | 'tasks' | 'goals' | 'goal-detail' | 'input' | 'processing' | 'confirmation' | 'settings' | 'insights' | 'history' | 'onboarding' | 'daily-summary';

function App() {
  const [currentScreen, setCurrentScreen] = useState<Screen>('onboarding');
  const [selectedGoalId, setSelectedGoalId] = useState<string | null>(null);
  const [isProcessing, setIsProcessing] = useState(false);
  const [hasCompletedOnboarding, setHasCompletedOnboarding] = useState(false);
  const [toast, setToast] = useState<{ message: string; type: 'success' | 'error' } | null>(null);
  const [editingGoal, setEditingGoal] = useState<Goal | null>(null);
  const [detectedTasks, setDetectedTasks] = useState<string[]>([]);
  const [detectedGoals, setDetectedGoals] = useState<string[]>([]);
  const [wasVoiceInput, setWasVoiceInput] = useState(false);
  const [isDarkMode, setIsDarkMode] = useState(false);

  // Mock data
  const [tasks, setTasks] = useState<Task[]>([
    {
      id: '1',
      text: 'Buy groceries',
      completed: false,
      createdAt: new Date('2025-12-28'),
    },
    {
      id: '2',
      text: 'Call dentist',
      completed: false,
      createdAt: new Date('2025-12-29'),
    },
    {
      id: '3',
      text: 'Review design mockups',
      completed: true,
      createdAt: new Date('2025-12-27'),
      completedAt: new Date('2025-12-27'),
    },
    {
      id: '4',
      text: 'Send invoice to client',
      completed: true,
      createdAt: new Date('2025-12-26'),
      completedAt: new Date('2025-12-26'),
    },
  ]);

  const [goals, setGoals] = useState<Goal[]>([
    {
      id: 'g1',
      name: 'Motion Design',
      color: '#A78BFA',
      createdAt: new Date('2025-12-20'),
      entries: [
        {
          id: 'e1',
          date: new Date('2025-12-30'),
          text: 'Worked on easing curves and spring animations',
          didSomething: true,
        },
        {
          id: 'e2',
          date: new Date('2025-12-29'),
          didSomething: true,
        },
        {
          id: 'e3',
          date: new Date('2025-12-27'),
          text: 'Studied Framer Motion documentation',
          didSomething: true,
        },
      ],
    },
    {
      id: 'g2',
      name: 'Music Production',
      color: '#34D399',
      createdAt: new Date('2025-12-22'),
      entries: [
        {
          id: 'e4',
          date: new Date('2025-12-30'),
          text: 'Laid down drums for new track',
          didSomething: true,
        },
        {
          id: 'e5',
          date: new Date('2025-12-28'),
          didSomething: true,
        },
      ],
    },
    {
      id: 'g3',
      name: 'Fitness',
      color: '#F87171',
      createdAt: new Date('2025-12-15'),
      entries: [
        {
          id: 'e6',
          date: new Date('2025-12-30'),
          didSomething: true,
        },
        {
          id: 'e7',
          date: new Date('2025-12-29'),
          text: '30 min run + stretching',
          didSomething: true,
        },
      ],
    },
  ]);

  const showToast = (message: string, type: 'success' | 'error' = 'success') => {
    setToast({ message, type });
    setTimeout(() => setToast(null), 3000);
  };

  const toggleTask = (id: string) => {
    setTasks(tasks.map(task => {
      if (task.id === id) {
        const newCompleted = !task.completed;
        showToast(newCompleted ? 'Task completed!' : 'Task reopened');
        return { 
          ...task, 
          completed: newCompleted,
          completedAt: newCompleted ? new Date() : undefined
        };
      }
      return task;
    }));
  };

  const deleteTask = (id: string) => {
    setTasks(tasks.filter(task => task.id !== id));
    showToast('Task deleted');
  };

  const editTask = (id: string, newText: string) => {
    setTasks(tasks.map(task => 
      task.id === id ? { ...task, text: newText } : task
    ));
    showToast('Task updated');
  };

  const deleteGoal = (id: string) => {
    setGoals(goals.filter(goal => goal.id !== id));
    showToast('Goal removed');
    setCurrentScreen('goals');
  };

  const updateGoal = (id: string, name: string, color: string) => {
    setGoals(goals.map(goal =>
      goal.id === id ? { ...goal, name, color } : goal
    ));
    showToast('Goal updated');
    setEditingGoal(null);
  };

  const handleInput = (text: string, isVoice: boolean) => {
    setCurrentScreen('processing');
    setIsProcessing(true);
    setWasVoiceInput(isVoice);

    // Simulate processing
    setTimeout(() => {
      // Mock categorization logic
      const input = text.toLowerCase();
      const sentences = text.split(',').map(s => s.trim()).filter(s => s.length > 0);
      
      const tasksFound: string[] = [];
      const goalsFound: string[] = [];
      
      sentences.forEach(sentence => {
        const lower = sentence.toLowerCase();
        if (lower.includes('learn') || lower.includes('practice') || lower.includes('work on') || lower.includes('improve')) {
          goalsFound.push(sentence.replace(/^(learn|practice|work on|improve)\s*/i, '').trim());
        } else {
          tasksFound.push(sentence);
        }
      });

      setDetectedTasks(tasksFound);
      setDetectedGoals(goalsFound);
      setIsProcessing(false);

      // If voice input, show confirmation screen
      if (isVoice) {
        setCurrentScreen('confirmation');
      } else {
        // For typed input, add directly (original behavior)
        addConfirmedItems(tasksFound, goalsFound);
      }
    }, 2000);
  };

  const addConfirmedItems = (confirmedTasks: string[], confirmedGoals: string[]) => {
    // Add confirmed tasks
    const newTasks: Task[] = confirmedTasks.map(text => ({
      id: `t${Date.now()}-${Math.random()}`,
      text: text,
      completed: false,
      createdAt: new Date(),
    }));
    
    // Add confirmed goals
    const newGoals: Goal[] = confirmedGoals.map(name => ({
      id: `g${Date.now()}-${Math.random()}`,
      name: name,
      color: ['#60A5FA', '#A78BFA', '#34D399', '#F87171', '#FBBF24'][Math.floor(Math.random() * 5)],
      createdAt: new Date(),
      entries: [],
    }));

    if (newTasks.length > 0) {
      setTasks([...tasks, ...newTasks]);
      showToast(`${newTasks.length} ${newTasks.length === 1 ? 'task' : 'tasks'} added!`);
    }
    
    if (newGoals.length > 0) {
      setGoals([...goals, ...newGoals]);
      showToast(`${newGoals.length} ${newGoals.length === 1 ? 'goal' : 'goals'} created!`);
    }

    setCurrentScreen('home');
    setDetectedTasks([]);
    setDetectedGoals([]);
    setWasVoiceInput(false);
  };

  const addGoalEntry = (goalId: string, text?: string) => {
    setGoals(goals.map(goal => {
      if (goal.id === goalId) {
        const newEntry: GoalEntry = {
          id: `entry-${Date.now()}`,
          date: new Date(),
          text: text,
          didSomething: true,
        };
        showToast(text ? 'Progress logged!' : 'Marked as done!');
        return {
          ...goal,
          entries: [...goal.entries, newEntry],
        };
      }
      return goal;
    }));
  };

  const openGoalDetail = (goalId: string) => {
    setSelectedGoalId(goalId);
    setCurrentScreen('goal-detail');
  };

  const completeOnboarding = () => {
    setHasCompletedOnboarding(true);
    setCurrentScreen('home');
  };

  const renderScreen = () => {
    if (currentScreen === 'onboarding' && !hasCompletedOnboarding) {
      return <OnboardingScreen onComplete={completeOnboarding} />;
    }

    if (isProcessing) {
      return <ProcessingScreen />;
    }

    if (currentScreen === 'input') {
      return (
        <InputScreen
          onSubmit={handleInput}
          onBack={() => setCurrentScreen('home')}
        />
      );
    }

    if (currentScreen === 'confirmation') {
      return (
        <ConfirmationScreen
          detectedTasks={detectedTasks}
          detectedGoals={detectedGoals}
          onConfirm={addConfirmedItems}
          onBack={() => setCurrentScreen('input')}
        />
      );
    }

    if (currentScreen === 'settings') {
      return (
        <SettingsScreen
          onBack={() => setCurrentScreen('home')}
          onNavigate={(screen) => setCurrentScreen(screen as Screen)}
          isDarkMode={isDarkMode}
          onToggleDarkMode={() => setIsDarkMode(!isDarkMode)}
        />
      );
    }

    if (currentScreen === 'insights') {
      return (
        <InsightsScreen
          tasks={tasks}
          goals={goals}
          onBack={() => setCurrentScreen('settings')}
        />
      );
    }

    if (currentScreen === 'history') {
      return (
        <HistoryScreen
          tasks={tasks}
          onBack={() => setCurrentScreen('settings')}
        />
      );
    }

    if (currentScreen === 'daily-summary') {
      return (
        <DailySummary
          tasks={tasks}
          goals={goals}
          onBack={() => setCurrentScreen('home')}
        />
      );
    }

    if (currentScreen === 'goal-detail' && selectedGoalId) {
      const goal = goals.find(g => g.id === selectedGoalId);
      if (goal) {
        return (
          <GoalDetail
            goal={goal}
            onBack={() => setCurrentScreen('goals')}
            onAddEntry={addGoalEntry}
            onEdit={() => setEditingGoal(goal)}
            onDelete={deleteGoal}
          />
        );
      }
    }

    switch (currentScreen) {
      case 'tasks':
        return (
          <TasksView
            tasks={tasks}
            onToggle={toggleTask}
            onDelete={deleteTask}
            onEdit={editTask}
          />
        );
      case 'goals':
        return <GoalsView goals={goals} onGoalClick={openGoalDetail} />;
      default:
        return (
          <Home
            tasks={tasks}
            goals={goals}
            onToggle={toggleTask}
            onGoalClick={openGoalDetail}
            onNavigateToSettings={() => setCurrentScreen('settings')}
            onNavigateToDailySummary={() => setCurrentScreen('daily-summary')}
          />
        );
    }
  };

  const showNav = !isProcessing && 
    currentScreen !== 'input' && 
    currentScreen !== 'confirmation' &&
    currentScreen !== 'goal-detail' && 
    currentScreen !== 'settings' && 
    currentScreen !== 'insights' && 
    currentScreen !== 'history' && 
    currentScreen !== 'onboarding' &&
    currentScreen !== 'daily-summary';

  return (
    <div className={`min-h-screen ${isDarkMode ? 'dark bg-gradient-to-br from-gray-900 via-gray-800 to-purple-900/30' : 'bg-gradient-to-br from-gray-50 via-blue-50/30 to-purple-50/30'} flex items-center justify-center p-4 transition-colors duration-300`}>
      {/* Mobile frame */}
      <div className={`w-full max-w-md h-[812px] ${isDarkMode ? 'bg-gray-900/40 border-gray-700/50' : 'bg-white/40 border-white/50'} backdrop-blur-xl border rounded-[3rem] overflow-hidden shadow-apple-lg flex flex-col relative transition-colors duration-300`}>
        {/* Screen content */}
        <div className="flex-1 overflow-auto">
          {renderScreen()}
        </div>

        {/* Bottom Navigation */}
        {showNav && (
          <nav className={`${isDarkMode ? 'bg-gray-900/80 border-gray-700/50' : 'bg-white/85 border-white/30'} border-t backdrop-blur-2xl flex items-center justify-around px-2 pb-6 pt-3 transition-colors duration-300`}>
            <button
              onClick={() => setCurrentScreen('home')}
              className={`flex flex-col items-center gap-1 px-6 py-2 rounded-xl transition-all ${
                currentScreen === 'home' 
                  ? isDarkMode 
                    ? 'text-blue-400 bg-blue-500/20' 
                    : 'text-blue-600 bg-blue-50/50'
                  : isDarkMode
                    ? 'text-gray-400 hover:text-gray-200'
                    : 'text-gray-500 hover:text-gray-900'
              }`}
            >
              <HomeIcon size={24} strokeWidth={2.5} />
              <span className="text-[11px] tracking-tight">Home</span>
            </button>

            <button
              onClick={() => setCurrentScreen('tasks')}
              className={`flex flex-col items-center gap-1 px-6 py-2 rounded-xl transition-all ${
                currentScreen === 'tasks' 
                  ? isDarkMode 
                    ? 'text-blue-400 bg-blue-500/20' 
                    : 'text-blue-600 bg-blue-50/50'
                  : isDarkMode
                    ? 'text-gray-400 hover:text-gray-200'
                    : 'text-gray-500 hover:text-gray-900'
              }`}
            >
              <CheckSquare size={24} strokeWidth={2.5} />
              <span className="text-[11px] tracking-tight">Tasks</span>
            </button>

            <button
              onClick={() => setCurrentScreen('goals')}
              className={`flex flex-col items-center gap-1 px-6 py-2 rounded-xl transition-all ${
                currentScreen === 'goals' 
                  ? isDarkMode 
                    ? 'text-blue-400 bg-blue-500/20' 
                    : 'text-blue-600 bg-blue-50/50'
                  : isDarkMode
                    ? 'text-gray-400 hover:text-gray-200'
                    : 'text-gray-500 hover:text-gray-900'
              }`}
            >
              <Target size={24} strokeWidth={2.5} />
              <span className="text-[11px] tracking-tight">Goals</span>
            </button>
          </nav>
        )}

        {/* Floating Action Button */}
        {showNav && (
          <button
            onClick={() => setCurrentScreen('input')}
            className={`absolute bottom-28 right-6 w-14 h-14 ${isDarkMode ? 'bg-gradient-to-br from-blue-600 to-blue-700' : 'bg-gradient-to-br from-blue-500 to-blue-600'} text-white rounded-2xl flex items-center justify-center shadow-apple-lg hover:scale-105 active:scale-95 transition-all`}
          >
            <Plus size={26} strokeWidth={2.5} />
          </button>
        )}

        {/* Toast Notifications */}
        {toast && <Toast message={toast.message} type={toast.type} />}

        {/* Edit Goal Modal */}
        {editingGoal && (
          <EditGoalModal
            goal={editingGoal}
            onSave={updateGoal}
            onClose={() => setEditingGoal(null)}
          />
        )}
      </div>
    </div>
  );
}

export default App;