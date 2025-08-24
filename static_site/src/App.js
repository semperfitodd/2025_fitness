import React, { useEffect, useState } from 'react';
import { GoogleAuthProvider, onAuthStateChanged, signInWithPopup, signOut } from 'firebase/auth';
import Home from './screens/Home';
import InsertScreen from './screens/InsertScreen';
import GenerateWorkoutScreen from './screens/GenerateWorkoutScreen';
import Header from './components/Header';
import ErrorBoundary from './components/ErrorBoundary';
import { auth } from './utils/firebase';
import './styles/styles.css';

function App() {
    const [user, setUser] = useState(null);
    const [isLoading, setIsLoading] = useState(true);
    const [currentScreen, setCurrentScreen] = useState('home');

    useEffect(() => {
        const unsubscribe = onAuthStateChanged(auth, (currentUser) => {
            setUser(currentUser);
            setIsLoading(false);
        });

        return () => unsubscribe();
    }, []);

    const handleSignIn = async () => {
        const provider = new GoogleAuthProvider();
        try {
            const result = await signInWithPopup(auth, provider);
            setUser(result.user);
        } catch (error) {
            console.error("Error during Google Sign-In:", error.message);
        }
    };

    const handleSignOut = async () => {
        try {
            await signOut(auth);
            setUser(null);
        } catch (error) {
            console.error("Error signing out:", error.message);
        }
    };

    const renderScreen = () => {
        if (currentScreen === 'insert') {
            return <InsertScreen setCurrentScreen={setCurrentScreen} user={user} />;
        }
        if (currentScreen === 'generate-workout') {
            return <GenerateWorkoutScreen />;
        }
        return <Home user={user} />;
    };

    return (
        <ErrorBoundary>
            <div className="App">
                <Header user={user} onSignOut={handleSignOut} onNavigate={setCurrentScreen} />
                <main>
                    {isLoading ? (
                        <p>Loading...</p>
                    ) : user ? (
                        renderScreen()
                    ) : (
                        <div className="sign-in-container">
                            <div className="sign-in-card">
                                <h2>Welcome to Fitness Tracker</h2>
                                <p>Sign in to continue</p>
                                <button onClick={handleSignIn} className="google-signin-button">
                                    <svg className="google-icon" viewBox="0 0 24 24">
                                        <path fill="#4285F4" d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"/>
                                        <path fill="#34A853" d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"/>
                                        <path fill="#FBBC05" d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l2.85-2.22.81-.62z"/>
                                        <path fill="#EA4335" d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z"/>
                                    </svg>
                                    <span>Sign in with Google</span>
                                </button>
                            </div>
                        </div>
                    )}
                </main>
            </div>
        </ErrorBoundary>
    );
}

export default App;
