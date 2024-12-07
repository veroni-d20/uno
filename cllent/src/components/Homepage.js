import React, { useState } from 'react'
import { Link } from 'react-router-dom'
import randomCodeGenerator from '../utils/randomCodeGenerator'
import logo from "../assets/logo.png";

const Homepage = () => {
    const [roomCode, setRoomCode] = useState('')

    return (
        <div className='Homepage'>
            <div className='homepage-menu'>
                <img src={logo} alt="logo" width='160px' />
                <div className='homepage-form'>
                    <div className='homepage-join'>
                        <input type='text' style={{marginBottom:"60px"}} placeholder='Game Code' onChange={(event) => setRoomCode(event.target.value)} />
                        <Link to={`/play?roomCode=${roomCode}`}><button className="game-button green">JOIN GAME</button></Link>
                    <h1>OR</h1>
                    <div className='homepage-create'>
                        <Link to={`/play?roomCode=${randomCodeGenerator(5)}`}><button className="game-button orange">CREATE GAME</button></Link>
                    </div>
                    </div>
                </div>
            </div>
        </div>
    )
}

export default Homepage
