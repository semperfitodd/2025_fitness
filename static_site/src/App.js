import React, { useEffect, useState } from 'react';
import { getAuth, GoogleAuthProvider, onAuthStateChanged, signInWithPopup, signOut } from 'firebase/auth';
import Home from './screens/Home';
import InsertScreen from './screens/InsertScreen';
import GenerateWorkoutScreen from './screens/GenerateWorkoutScreen';
import Header from './components/Header';
import './styles/styles.css';

const auth = getAuth();

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
        <div className="App">
            <Header user={user} onSignOut={handleSignOut} onNavigate={setCurrentScreen} />
            <main>
                {isLoading ? (
                    <p>Loading...</p>
                ) : user ? (
                    renderScreen()
                ) : (
                    <button onClick={handleSignIn} className="sign-in-button">
                        Sign in with Google
                    </button>
                )}
            </main>
        </div>
    );
}

export default App;
