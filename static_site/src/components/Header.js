import React, { useState } from 'react';

const Header = ({ user, onSignOut, onNavigate }) => {
  const [menuOpen, setMenuOpen] = useState(false);

  const toggleMenu = () => {
    setMenuOpen(!menuOpen);
  };

  return (
    <header>
      <h1>Fitness App</h1>
      <p>Welcome, {user?.email || 'Guest'}</p>
      <button className="hamburger" onClick={toggleMenu} aria-label="Toggle menu">
        ☰
      </button>
      <nav className={`mobile-nav ${menuOpen ? 'active' : ''}`}>
        <button onClick={() => { toggleMenu(); onNavigate('home'); }}>Home</button>
        <button onClick={() => { toggleMenu(); onNavigate('insert'); }}>Insert</button>
        <button onClick={() => { toggleMenu(); onSignOut(); }}>Sign out</button>
      </nav>
      <div className="desktop-nav">
        <button onClick={() => onNavigate('home')}>Home</button>
        <button onClick={() => onNavigate('insert')}>Insert</button>
        <button onClick={onSignOut}>Sign out</button>
      </div>
    </header>
  );
};

export default Header;
