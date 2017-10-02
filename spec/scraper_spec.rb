# frozen_string_literal: true

require 'spec_helper'

describe 'alaveteli_versions' do
  describe '.main' do
    it 'can save to the database' do
      VCR.use_cassette('alaveteli_deployments') do
        expect { main }.to_not raise_error
      end
    end
  end

  describe '.get_version_information' do
    let(:records) do
      VCR.use_cassette('alaveteli_deployments') do
        deployments.map { |deployment| get_version_information(deployment) }
      end
    end

    it 'returns hashes', :aggregate_failures do
      records.each do |record|
        expect(record.is_a?(Hash)).to be true
      end
    end

    context 'when there are exceptions' do
      it 'sets an :error key' do
        expect(records.select { |r| r[:error] }.size).to be > 0
      end
    end
  end
end
