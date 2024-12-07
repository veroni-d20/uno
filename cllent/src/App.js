import './App.css'
import { Route } from 'react-router-dom'
import Homepage from './components/Homepage'

const App = () => {
  return (
    <div className="App">
      <Route path='/' exact component={Homepage} />
    </div>
  )
}

export default App