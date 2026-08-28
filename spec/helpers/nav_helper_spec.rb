require 'rails_helper'

RSpec.describe NavHelper, type: :helper do
  def at_path(path)
    allow(helper).to receive(:request).and_return(instance_double(ActionDispatch::Request, path: path))
  end

  describe '#tab_current?' do
    it 'lights the tab for its own page' do
      at_path('/meetings')
      expect(helper.tab_current?('/meetings')).to be(true)
    end

    it 'stays lit for pages beneath it' do
      at_path('/meetings/12')
      expect(helper.tab_current?('/meetings')).to be(true)
    end

    it 'is not lit for a different section' do
      at_path('/archives')
      expect(helper.tab_current?('/meetings')).to be(false)
    end

    # "/" is a prefix of every path, so the generic prefix rule would light Home
    # on every page in the app.
    it 'lights Home only on the front page' do
      at_path('/')
      expect(helper.tab_current?('/')).to be(true)

      at_path('/meetings')
      expect(helper.tab_current?('/')).to be(false)
    end
  end

  describe '#section_root?' do
    it 'is true for the destinations the bottom bar already reaches' do
      ['/', '/meetings', '/archives', '/stats', '/wishlist'].each do |path|
        at_path(path)
        expect(helper.section_root?).to be(true), "expected #{path} to be a section root"
      end
    end

    it 'is false for a page you drilled into' do
      at_path('/meetings/12')
      expect(helper.section_root?).to be(false)
    end
  end
end
