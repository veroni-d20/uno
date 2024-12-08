import React, { useState } from "react";
import { Link } from "react-router-dom";
import randomCodeGenerator from "../utils/randomCodeGenerator";
import logo from "../assets/logo.png";
import { useAccount, useConnect } from "@starknet-react/core";

const Homepage = () => {
  const [roomCode, setRoomCode] = useState("");
  const { connect, connectors } = useConnect();
  const { address } = useAccount();
  const isConnected = false;

  return (
    <div className="Homepage select-none">
      <div className="homepage-menu max-w-[1240px] mx-auto w-full text-center ">
        {!isConnected ? (
          <div>
            <img src={logo} alt="logo" width="160px" className="mx-auto" />
            <div className="my-10 flex justify-center ">
              <div>
                {connectors.map((connector) => (
                  <button className="game-button" onClick={() => connect({ connector })}>
                    Connect {connector.id}
                  </button>
                ))}
                <p>{address}</p>
              </div>
            </div>
          </div>
        ) : (
          <div>
            <div className="mb-5 flex justify-center ">
              <img src={logo} alt="logo" width="160px" className="mx-auto" />

              <div className="my-auto mx-10">
                <div>
                  <p>{address}</p>
                </div>
              </div>
            </div>
          </div>
        )}
        <div className="homepage-menu">
          {/* <img src={logo} alt="logo" width="160px" /> */}
          <div className="homepage-form">
            <div className="homepage-join">
              <input
                type="text"
                style={{ marginBottom: "60px" }}
                placeholder="Game Code"
                onChange={(event) => setRoomCode(event.target.value)}
              />
              <div className="game-options">
                <Link to={`/play?roomCode=${roomCode}`}>
                  <button className="game-button green">JOIN GAME</button>
                </Link>
                <h1>OR</h1>
                <Link to={`/play?roomCode=${randomCodeGenerator(5)}`}>
                  <button className="game-button orange">CREATE GAME</button>
                </Link>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default Homepage;
