import "./App.css";
import { Route } from "react-router-dom";
import Homepage from "./components/Homepage";
import Game from "./components/Game";
import StarknetProvider from "./components/starknet-provider";

const App = () => {
  return (
    <div className="App">
      <StarknetProvider>
        <Route path="/" exact component={Homepage} />
        <Route path="/play" exact component={Game} />
      </StarknetProvider>
    </div>
  );
};

export default App;
