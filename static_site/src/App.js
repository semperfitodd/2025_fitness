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
      return <InsertScreen />;
    }
    return <Home />;
  };

  return (
    <div className="App">
      {/* Ensure Header is Rendered Once */}
      <Header user={user} onSignOut={handleSignOut} onNavigate={setCurrentScreen} />
      <main>
        {isLoading ? (
          <p>Loading...</p>
        ) : user ? (
          renderScreen()
        ) : (
          <button onClick={handleSignIn}>Sign in with Google</button>
        )}
      </main>
    </div>
  );
}

export default App;