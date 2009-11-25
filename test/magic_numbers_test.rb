require 'test_helper'

setup_db

class Foo < ActiveRecord::Base

  enum_attribute     :state, :values => [:active, :pending, :passive, :deleted]
  bitfield_attribute :roles, :values => [:user, :administrator, :moderator]

end

class MagicNumbersTest < ActiveSupport::TestCase

  def setup
    @foo = Foo.new(:state => :passive,
                   :roles => [:administrator, :user])
  end

  test "should correctly handle enum and bitfield attributes" do
    assert @foo.save
    assert_equal 2, @foo[:state]
    assert_equal 3, @foo[:roles]
  end

  test "should handle string values as well" do
    @foo.state = 'deleted'
    assert_equal 3, @foo[:state]
    assert_equal :deleted, @foo.state

    @foo.roles = ['administrator', 'user']
    assert_equal 3, @foo[:roles]
    assert_equal [:user, :administrator], @foo.roles
  end

  test "should preserve values order in bitfield attribute" do
    @foo.roles = ['administrator', :moderator, 'user']
    assert_equal [:user, :administrator, :moderator], @foo.roles
  end

  test "should treat invalid values as nil values" do
    @foo.state = 'invalid_state'
    assert_nil @foo[:state]
  end

  test "should correctly handle right-to-left assigments" do
    state = @foo.state = :deleted
    assert_equal :deleted, state

    state = @foo.state = 'incorrect state'
    assert_equal 'incorrect state', state
  end

  test "should correctly report magic numbers for specified values" do
    assert_equal 3, Foo.magic_number_for(:roles, [:administrator, :user, nil, 'aalsdkajajs'])
    assert_equal 0, Foo.magic_number_for(:roles, [])
    assert_equal 1, Foo.magic_number_for(:state, 'pending')

    assert_nil Foo.magic_number_for(:state, 'invalid state value')
  end

end
