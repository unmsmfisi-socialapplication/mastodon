import { fromJS } from 'immutable';

import renderer from 'react-test-renderer';

import AvatarComposite from '../avatar_composite';

describe('<AvatarComposite />', () => {
  const accounts = fromJS([
    { id: '1', username: 'alice', acct: 'alice@domain.com', display_name: 'Alice', avatar: '/static/alice.jpg' },
    { id: '2', username: 'bob', acct: 'bob@domain.com', display_name: 'Bob', avatar: '/static/bob.jpg' },
    { id: '3', username: 'charlie', acct: 'charlie@domain.com', display_name: 'Charlie', avatar: '/static/charlie.jpg' },
    { id: '4', username: 'dave', acct: 'dave@domain.com', display_name: 'Dave', avatar: '/static/dave.jpg' },
  ]);

  it('renders correctly with a list of accounts and size 100', () => {
    const component = renderer.create(
      <AvatarComposite accounts={accounts} size={100} />
    );
    const tree = component.toJSON();
    expect(tree).toMatchSnapshot();
  });

  it('renders correctly with more than 4 accounts', () => {
    const accountsExtended = fromJS([
      ...accounts.toJS(),
      { id: '5', username: 'eve', acct: 'eve@domain.com', display_name: 'Eve', avatar: '/static/eve.jpg' },
      { id: '6', username: 'frank', acct: 'frank@domain.com', display_name: 'Frank', avatar: '/static/frank.jpg' },
    ]);
    const component = renderer.create(
      <AvatarComposite accounts={accountsExtended} size={100} />
    );
    const tree = component.toJSON();
    expect(tree).toMatchSnapshot();
  });

  it('renders correctly with animation disabled', () => {
    const component = renderer.create(
      <AvatarComposite accounts={accounts} size={100} animate={false} />
    );
    const tree = component.toJSON();
    expect(tree).toMatchSnapshot();
  });

  it('renders correctly with less than 4 accounts', () => {
    const fewAccounts = fromJS([
      { id: '1', username: 'alice', acct: 'alice@domain.com', display_name: 'Alice', avatar: '/static/alice.jpg' },
      { id: '2', username: 'bob', acct: 'bob@domain.com', display_name: 'Bob', avatar: '/static/bob.jpg' },
    ]);
    const component = renderer.create(
      <AvatarComposite accounts={fewAccounts} size={100} />
    );
    const tree = component.toJSON();
    expect(tree).toMatchSnapshot();
  });
});
