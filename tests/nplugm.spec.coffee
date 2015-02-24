_ = require('lodash-contrib')
sinon = require('sinon')
chai = require('chai')
chai.use(require('sinon-chai'))
expect = chai.expect
Nplugm = require('../lib/nplugm')
npmCommands = require('../lib/npm-commands')

describe 'Nplugm:', ->

	describe '#constructor()', ->

		it 'should throw an error if no prefix', ->
			expect ->
				new Nplugm()
			.to.throw('Missing prefix argument')

		it 'should throw an error if prefix is not a string', ->
			expect ->
				new Nplugm(123)
			.to.throw('Invalid prefix argument: not a string: 123')

		it 'should make the prefix accesible from the instance', ->
			nplugm = new Nplugm('foobar-')
			expect(nplugm.prefix).to.equal('foobar-')

	describe '#list()', ->

		describe 'given an error', ->

			beforeEach ->
				@nplugm = new Nplugm('foobar-')
				@npmCommandsListStub = sinon.stub(npmCommands, 'list')
				@npmCommandsListStub.yields(new Error('List Error'))

			afterEach ->
				@npmCommandsListStub.restore()

			it 'should propagate the error', (done) ->
				@nplugm.list (error, plugins) ->
					expect(error).to.be.an.instanceof(Error)
					expect(error.message).to.equal('List Error')
					expect(plugins).to.not.exist
					done()

			it 'should not throw if no callback', ->
				expect =>
					@nplugm.list()
				.to.not.throw(Error)

		describe 'given a list of plugins', ->

			beforeEach ->
				@nplugm = new Nplugm('foobar-')
				@npmCommandsListStub = sinon.stub(npmCommands, 'list')
				@npmCommandsListStub.yields null, [
					'foobar-foo'
					'hello-world'
					'foobarqux'
					'foobar-bar'
				]

			afterEach ->
				@npmCommandsListStub.restore()

			it 'should filter by the prefix', (done) ->
				@nplugm.list (error, plugins) ->
					expect(error).to.not.exist
					expect(plugins).to.deep.equal [
						'foobar-foo'
						'foobar-bar'
					]
					done()

			it 'should not throw if no callback', ->
				expect =>
					@nplugm.list()
				.to.not.throw(Error)

		describe 'given no installed plugins', ->

			beforeEach ->
				@nplugm = new Nplugm('foobar-')
				@npmCommandsListStub = sinon.stub(npmCommands, 'list')
				@npmCommandsListStub.yields null, []

			afterEach ->
				@npmCommandsListStub.restore()

			it 'should return an empty array', (done) ->
				@nplugm.list (error, plugins) ->
					expect(error).to.not.exist
					expect(plugins).to.deep.equal([])
					done()

			it 'should not throw if no callback', ->
				expect =>
					@nplugm.list()
				.to.not.throw(Error)

	describe '#install()', ->

		it 'should throw if no plugin', ->
			nplugm = new Nplugm('foobar-')
			expect ->
				nplugm.install(null, _.noop)
			.to.throw('Missing plugin argument')

		it 'should throw if plugin is not a string', ->
			nplugm = new Nplugm('foobar-')
			expect ->
				nplugm.install(123, _.noop)
			.to.throw('Invalid plugin argument: not a string: 123')

		describe 'given a valid plugin name', ->

			beforeEach ->
				@nplugm = new Nplugm('foobar-')
				@npmCommandsInstallStub = sinon.stub(npmCommands, 'install')

			afterEach ->
				@npmCommandsInstallStub.restore()

			it 'should preppend the prefix', ->
				@nplugm.install('hello', _.noop)
				expect(@npmCommandsInstallStub).to.have.been.calledOnce
				expect(@npmCommandsInstallStub).to.have.been.calledWith('foobar-hello')

			it 'should not throw if no callback', ->
				expect =>
					@nplugm.install('hello')
				.to.not.throw(Error)

	describe '#remove()', ->

		it 'should throw if no plugin', ->
			nplugm = new Nplugm('foobar-')
			expect ->
				nplugm.remove(null, _.noop)
			.to.throw('Missing plugin argument')

		it 'should throw if plugin is not a string', ->
			nplugm = new Nplugm('foobar-')
			expect ->
				nplugm.remove(123, _.noop)
			.to.throw('Invalid plugin argument: not a string: 123')

		describe 'given a valid plugin name', ->

			beforeEach ->
				@nplugm = new Nplugm('foobar-')
				@npmCommandsRemoveStub = sinon.stub(npmCommands, 'remove')

			afterEach ->
				@npmCommandsRemoveStub.restore()

			it 'should preppend the prefix', ->
				@nplugm.remove('hello', _.noop)
				expect(@npmCommandsRemoveStub).to.have.been.calledOnce
				expect(@npmCommandsRemoveStub).to.have.been.calledWith('foobar-hello')

			it 'should not throw if no callback', ->
				expect =>
					@nplugm.remove('hello')
				.to.not.throw(Error)

	describe '#has()', ->

		it 'should throw if no plugin', ->
			nplugm = new Nplugm('foobar-')
			expect ->
				nplugm.has(null, _.noop)
			.to.throw('Missing plugin argument')

		it 'should throw if plugin is not a string', ->
			nplugm = new Nplugm('foobar-')
			expect ->
				nplugm.has(123, _.noop)
			.to.throw('Invalid plugin argument: not a string: 123')

		describe 'given an error', ->

			beforeEach ->
				@nplugm = new Nplugm('foobar-')
				@npmCommandsListStub = sinon.stub(npmCommands, 'list')
				@npmCommandsListStub.yields(new Error('List Error'))

			afterEach ->
				@npmCommandsListStub.restore()

			it 'should propagate the error', (done) ->
				@nplugm.has 'hello', (error, plugins) ->
					expect(error).to.be.an.instanceof(Error)
					expect(error.message).to.equal('List Error')
					expect(plugins).to.not.exist
					done()

			it 'should not throw if no callback', ->
				expect =>
					@nplugm.has('hello')
				.to.not.throw(Error)

		describe 'given a list of plugins', ->

			beforeEach ->
				@nplugm = new Nplugm('foobar-')
				@npmCommandsListStub = sinon.stub(npmCommands, 'list')
				@npmCommandsListStub.yields null, [
					'foobar-foo'
					'hello-world'
					'foobarqux'
					'foobar-bar'
				]

			afterEach ->
				@npmCommandsListStub.restore()

			describe 'given it has the plugin', ->

				it 'should return true', (done) ->
					@nplugm.has 'foo', (error, hasPlugin) ->
						expect(error).to.not.exist
						expect(hasPlugin).to.be.true
						done()

				it 'should not throw if no callback', ->
					expect =>
						@nplugm.has('foo')
					.to.not.throw(Error)

			describe 'given it does not have the plugin', ->

				it 'should return false', (done) ->
					@nplugm.has 'baz', (error, hasPlugin) ->
						expect(error).to.not.exist
						expect(hasPlugin).to.be.false
						done()

				it 'should not throw if no callback', ->
					expect =>
						@nplugm.has('baz')
					.to.not.throw(Error)

	describe '#require()', ->

		it 'should throw if no plugin', ->
			nplugm = new Nplugm('foobar-')
			expect ->
				nplugm.require(null)
			.to.throw('Missing plugin argument')

		it 'should throw if plugin is not a string', ->
			nplugm = new Nplugm('foobar-')
			expect ->
				nplugm.require(123)
			.to.throw('Invalid plugin argument: not a string: 123')
