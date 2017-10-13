# frozen_string_literal: true

require_relative 'integration_helper'

describe 'repository with hiera 5' do
  context 'with --hiera-path and per-item data directory' do
    it 'should fail because per-item datadir is not supported with --hiera-path' do
      argv = ['-n', 'rspec-node.github.net']
      hash = {
        hiera_config: 'config/hiera5-global.yaml',
        spec_fact_file: 'facts.yaml',
        spec_repo: 'hiera5',
        spec_catalog_old: 'catalog-empty.json'
      }
      result = OctocatalogDiff::Integration.integration(hash.merge(argv: argv))
      expect(result.exitcode).to eq(-1), OctocatalogDiff::Integration.format_exception(result)
      expect(result.exception).to be_a_kind_of(ArgumentError)
      expect(result.exception.message).to match(/Hierarchy item .+ has a datadir/)
    end
  end

  context 'with --hiera-path-strip and per-item data directory' do
    if ENV['PUPPET_VERSION'].start_with?('3')
      it 'should run but not use hiera values under puppet 3' do
        argv = ['-n', 'rspec-node.github.net', '--hiera-path-strip', '/var/lib/puppet']
        hash = {
          hiera_config: 'config/hiera5-global.yaml',
          spec_fact_file: 'facts.yaml',
          spec_repo: 'hiera5',
          spec_catalog_old: 'catalog-empty.json'
        }
        result = OctocatalogDiff::Integration.integration(hash.merge(argv: argv))
        expect(result.exitcode).to eq(2), OctocatalogDiff::Integration.format_exception(result)

        to_catalog = result.to

        param1 = { 'content' => 'hard-coded' }
        expect(to_catalog.resource(type: 'File', title: '/tmp/nodes')['parameters']).to eq(param1)

        param2 = { 'content' => 'hard-coded' }
        expect(to_catalog.resource(type: 'File', title: '/tmp/special')['parameters']).to eq(param2)

        param3 = { 'content' => 'hard-coded' }
        expect(to_catalog.resource(type: 'File', title: '/tmp/common')['parameters']).to eq(param3)
      end
    else
      it 'should succeed in building the catalog' do
        argv = ['-n', 'rspec-node.github.net', '--hiera-path-strip', '/var/lib/puppet']
        hash = {
          hiera_config: 'config/hiera5-global.yaml',
          spec_fact_file: 'facts.yaml',
          spec_repo: 'hiera5',
          spec_catalog_old: 'catalog-empty.json'
        }
        result = OctocatalogDiff::Integration.integration(hash.merge(argv: argv))
        expect(result.exitcode).to eq(2), OctocatalogDiff::Integration.format_exception(result)

        to_catalog = result.to

        param1 = { 'content' => 'Greets from nodes' }
        expect(to_catalog.resource(type: 'File', title: '/tmp/nodes')['parameters']).to eq(param1)

        param2 = { 'content' => 'Greets from special' }
        expect(to_catalog.resource(type: 'File', title: '/tmp/special')['parameters']).to eq(param2)

        param3 = { 'content' => 'Greets from common' }
        expect(to_catalog.resource(type: 'File', title: '/tmp/common')['parameters']).to eq(param3)
      end
    end
  end

  context 'with hiera 5 non-global, environment specific configuration' do
    if ENV['PUPPET_VERSION'].start_with?('3')
      it 'should run but not use hiera values under puppet 3' do
        argv = ['-n', 'rspec-node.github.net']
        hash = {
          spec_fact_file: 'facts.yaml',
          spec_repo: 'hiera5',
          spec_catalog_old: 'catalog-empty.json'
        }
        result = OctocatalogDiff::Integration.integration(hash.merge(argv: argv))
        expect(result.exitcode).to eq(2), OctocatalogDiff::Integration.format_exception(result)

        to_catalog = result.to

        param1 = { 'content' => 'hard-coded' }
        expect(to_catalog.resource(type: 'File', title: '/tmp/nodes')['parameters']).to eq(param1)

        param2 = { 'content' => 'hard-coded' }
        expect(to_catalog.resource(type: 'File', title: '/tmp/special')['parameters']).to eq(param2)

        param3 = { 'content' => 'hard-coded' }
        expect(to_catalog.resource(type: 'File', title: '/tmp/common')['parameters']).to eq(param3)
      end
    else
      it 'should succeed in building the catalog' do
        argv = ['-n', 'rspec-node.github.net']
        hash = {
          spec_fact_file: 'facts.yaml',
          spec_repo: 'hiera5',
          spec_catalog_old: 'catalog-empty.json'
        }
        result = OctocatalogDiff::Integration.integration(hash.merge(argv: argv))
        expect(result.exitcode).to eq(2), OctocatalogDiff::Integration.format_exception(result)

        to_catalog = result.to

        param1 = { 'content' => 'Greets from nodes' }
        expect(to_catalog.resource(type: 'File', title: '/tmp/nodes')['parameters']).to eq(param1)

        param2 = { 'content' => 'Greets from special' }
        expect(to_catalog.resource(type: 'File', title: '/tmp/special')['parameters']).to eq(param2)

        param3 = { 'content' => 'Greets from common' }
        expect(to_catalog.resource(type: 'File', title: '/tmp/common')['parameters']).to eq(param3)
      end
    end
  end
end
