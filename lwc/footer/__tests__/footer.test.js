import { createElement } from 'lwc';
import footer from '../footer';

const mockEmail = 'test@test.com';
const mockFooterLabel = 'test';

jest.mock('@salesforce/label/c.TCPFooterEmail', () => ({ default: 'test@test.com' }), { virtual: true });

jest.mock('@salesforce/label/c.FooterLabel', () => ({ default: 'test' }), { virtual: true });


describe('c-community-header component tests', () => {
  afterEach(() => {
    // jsdom instance are shared across the dom
    // reset the DOM
    while (document.body.firstChild) {
      document.body.removeChild(document.body.firstChild);
    }
    // Prevent data saved on mocks from leaking between tests
    jest.clearAllMocks();
  });

  // reusable method for all test cases
  const initializeElement = () => {
    const element = createElement('c-footer', {
      is: footer,
    });
    document.body.appendChild(element);
    return element;
  };

  // Helper function to wait until the microtask queue is empty. This is needed for promise
  // timing when calling imperative Apex.
  const flushPromises = () => new Promise(resolve => setImmediate(resolve));

  it('Check for component load', () => {
    const element = initializeElement();
    const anchorEl = element.shadowRoot.querySelector('.text-default a');
    return flushPromises().then(() => {
      expect(anchorEl.textContent).toEqual(mockEmail);
    });
  });

  it('Check for component label', () => {
    const element = initializeElement();
    const anchorEl = element.shadowRoot.querySelector('.text-default');
    return flushPromises().then(() => {
      const text = `${mockFooterLabel} ${mockEmail}`;
      expect(anchorEl.textContent).toMatch(text);
    });
  });
});
