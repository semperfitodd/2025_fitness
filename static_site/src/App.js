import React, { useState, useEffect } from 'react';
import { getAuth, onAuthStateChanged, signOut, GoogleAuthProvider, signInWithPopup } from 'firebase/auth';
import Home from './screens/Home';
import InsertScreen from './screens/InsertScreen';
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
      setUser(result.user); // Set the signed-in user
    } catch (error) {
      console.error("Error during Google Sign-In:", error.message);
      alert("Sign-in failed. Please try again.");
    }
  };

  const handleSignOut = async () => {
    try {
      await signOut(auth);
      setUser(null);
      alert("You have signed out.");
    } catch (error) {
      console.error("Error signing out:", error.message);
    }
  };

  const formatDate = () => {
    const options = { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' };
    return new Date().toLocaleDateString('en-US', options);
  };

  const renderScreen = () => {
    if (currentScreen === 'insert') {
      return <InsertScreen />;
    }
    return <Home />;
  };

  return (
    <div className="App">
      <Header user={user} onSignOut={handleSignOut} onNavigate={setCurrentScreen} />
      <header className="App-header">
        <h1>Todd Bernson's 2024 Fitness Goals Dashboard</h1>
        <h2>{formatDate()}</h2>
        {isLoading ? (
          <p>Loading...</p>
        ) : user ? (
          renderScreen()
        ) : (
          <button onClick={handleSignIn}>Sign in with Google</button>
        )}
      </header>
    </div>
  );
}

export default App;
