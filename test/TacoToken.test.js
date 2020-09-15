const { expectRevert } = require('@openzeppelin/test-helpers');
const TacoToken = artifacts.require('TacoToken');

contract('TacoToken', ([alice, bob, carol]) => {
    beforeEach(async () => {
        this.taco = await TacoToken.new({ from: alice });
    });

    it('should have correct name and symbol and decimal', async () => {
        const name = await this.taco.name();
        const symbol = await this.taco.symbol();
        const decimals = await this.taco.decimals();
        assert.equal(name.valueOf(), 'TacoToken');
        assert.equal(symbol.valueOf(), 'TACO');
        assert.equal(decimals.valueOf(), '18');
    });

    it('should only allow owner to mint token', async () => {
        await this.taco.mint(alice, '100', { from: alice });
        await this.taco.mint(bob, '1000', { from: alice });
        await expectRevert(
            this.taco.mint(carol, '1000', { from: bob }),
            'Ownable: caller is not the owner',
        );
        const totalSupply = await this.taco.totalSupply();
        const aliceBal = await this.taco.balanceOf(alice);
        const bobBal = await this.taco.balanceOf(bob);
        const carolBal = await this.taco.balanceOf(carol);
        assert.equal(totalSupply.valueOf(), '1100');
        assert.equal(aliceBal.valueOf(), '100');
        assert.equal(bobBal.valueOf(), '1000');
        assert.equal(carolBal.valueOf(), '0');
    });

    it('should supply token transfers properly', async () => {
        await this.taco.mint(alice, '100', { from: alice });
        await this.taco.mint(bob, '1000', { from: alice });
        await this.taco.transfer(carol, '10', { from: alice });
        await this.taco.transfer(carol, '100', { from: bob });
        const totalSupply = await this.taco.totalSupply();
        const aliceBal = await this.taco.balanceOf(alice);
        const bobBal = await this.taco.balanceOf(bob);
        const carolBal = await this.taco.balanceOf(carol);
        assert.equal(totalSupply.valueOf(), '1100');
        assert.equal(aliceBal.valueOf(), '90');
        assert.equal(bobBal.valueOf(), '900');
        assert.equal(carolBal.valueOf(), '110');
    });

    it('should fail if you try to do bad transfers', async () => {
        await this.taco.mint(alice, '100', { from: alice });
        await expectRevert(
            this.taco.transfer(carol, '110', { from: alice }),
            'ERC20: transfer amount exceeds balance',
        );
        await expectRevert(
            this.taco.transfer(carol, '1', { from: bob }),
            'ERC20: transfer amount exceeds balance',
        );
    });
  });
