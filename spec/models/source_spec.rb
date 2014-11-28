require 'rails_helper'

describe Source, :type => :model do
  it { is_expected.to belong_to(:group) }
  it { is_expected.to have_many(:traces).dependent(:destroy) }

  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_presence_of(:title) }
end
