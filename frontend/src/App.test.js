import { render, screen } from '@testing-library/react';
import App from './App';

test('renders Task Management App heading', () => {
  render(<App />);
  const linkElement = screen.getByText(/Task Management App/i);
  expect(linkElement).toBeInTheDocument();
});
