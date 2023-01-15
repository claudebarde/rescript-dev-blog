let test = "_This tutorial is the first part of a 3 part series of tutorials about writing Sapling contracts with CameLigo. The first tutorial (this one) is about a simple example that only handles XTZ, the second one will be about writing a Sapling contract that handles FA1.2 tokens, and the third one about writing a contract that handles FA2 tokens._

[Sapling](https://tezos.gitlab.io/active/sapling.html#sapling-integration) has been one of the greatest features brought to the Tezos blockchain in its recent upgrades. It provides an effective way to exchange tez and other fungible tokens in an anonymous way with an API simple enough to be understood and used quickly by every developer.

However, it didn’t get the expected traction for a couple of reasons: the first one may be because of [what happened to the creator of Tornado Cash](https://cointelegraph.com/news/ruling-to-keep-tornado-cash-developer-in-jail-for-90-days-sparks-backlash) and the fear a lot of developers now have to use technologies that hide on-chain transactions.

The second one could also be because of the way Sapling works: in order to effectively hide transactions coming in and out of a Sapling pool, you must have a flow of transactions consistent and large enough to make it difficult for the outside observer to understand who sent XTZ to whom.

Another reason may also be that writing a dapp that uses Sapling is more complicated than writing a more conventional one, although the entry barrier has now been lowered since [Taquito](https://tezostaquito.io/) introduced a [package specifically designed to interact with Sapling contracts](https://tezostaquito.io/docs/sapling/). If you are interested in knowing more about it, you can read the [tutorial](https://medium.com/ecad-labs-inc/using-sapling-with-taquito-649ccb248c95) I wrote about it.

But one of the main issues, in my opinion, that is slowing down the use of Sapling is the lack of understanding of the technology among developers and above all, the lack of tutorials to explain how it works and how easy it is to actually use!

This is what you will learn in this tutorial. After a quick introduction to Sapling, we will dive into the required code to implement a Sapling pool within a smart contract and exchange XTZ anonymously. You will learn about the basic elements you need to know to understand how a Sapling contract works, about the different types of transactions involved in a Sapling pool and by the end of the article, the `Tezos.sapling_verify_update` method will have no more secrets for you!

> Note: this tutorial assumes that you have a good knowledge of the CameLigo syntax for the Ligo language. You can find useful links at the bottom of this article to learn Ligo. The basic concepts of the language will not be explained, only new concepts related to the use of Sapling.

# Understanding Sapling

Although it may seem daunting, the mechanism behind a Sapling contract is very simple to understand.

A Sapling contract is a Tezos contract that includes a Sapling pool. Transactions can be sent to the contract and the contract can send transactions just like a regular contract, but transactions also happen inside the Sapling pool of the contract. 

The first concept that is essential to understand is the following: **only the transactions happening inside the Sapling pool are hidden**. Participants in the Sapling pool are given special addresses in the pool starting with \"*zet*\" and can exchange XTZ in an anonymous way within the pool.

However, the participants must send XTZ to the contract in a publicly visible way and can receive XTZ from the contract in an also publicly visible way.

This mechanism is illustrated in the diagram below:

![[sapling-flow.png]]

- **Shielding transactions** are incoming transactions, generally to bring XTZ to the contract that can then be exchanged within the Sapling pool
- **Unshielding transactions** are outgoing transactions, generally to send XTZ after they have been exchanged anonymously within the Sapling pool
- **Sapling transactions** are transactions happening within the Sapling pool that involve an exchange of XTZ. These are the hidden transactions involving addresses that start with \"*zet*\"

The balances of the participants in the Sapling pool are hidden and you must generate a `viewing key` from your `spending key` in order to check your own balance.

Now you understand why it is essential to have a lot of activity around a Sapling contract to make it efficient. If Alice sends 10 XTZ to a Sapling contract (visible transaction), transfers them to Bob within the Sapling pool (invisible transaction) before the contract transfers them to Bob (visible transaction) and there is no other transaction happening at the same time, it would be pretty clear that Bob received the XTZ from Alice!

> Note: this mechanism may seem like a limitation of Sapling, but it is actually a limitation that exists on every blockchain implementing a zero-knowledge mechanism for anonymous transactions.

# Designing the contract
The contract that we will write is a basic Sapling contract that will implement all the features of a Sapling contract: receiving and sending XTZ and allowing Sapling transactions within the pool. Creating the incoming transactions to the contract is outside of the scope of this tutorial, we will focus on how the contract handles them.

As the contract will be very simple, there will be a single entrypoint to call. The entrypoint will receive a list of transactions and loop through it to apply them. According to the result of the transaction, the contract will exchange XTZ within the obfuscated Sapling pool or create a transfer to send XTZ to the required recipient.

There are a few new types and methods to know in Ligo that handle Sapling features that will be the focus of the next paragraphs:
- 2 new types: `sapling_state` and `sapling_transaction`
- 1 new method: `Tezos.sapling_verify_update`

# Setting up the storage and the parameter
Let's have a look at the types we will set up for the contract:

![[sapling-code1.png]]

The `return` type should not be unfamiliar to you, it is the type of the value returned at the end of the execution of the contract.

You can see here 2 new types: `8 sapling_state` and `8 sapling_transaction`. The *8* argument in both types is the [size of the memo](https://tezos.gitlab.io/active/sapling.html#memo). `sapling_state` represents the state of the Sapling pool while `sapling_transaction` represents a valid Sapling transaction sent to the contract.

The Sapling transactions will be sent in a list, so we can iterate through the list and apply the transactions one by one.

# Sapling_verify_update
The core method of a Sapling contract in Ligo is `Tezos.sapling_verify_update`. This method is in charge of verifying any transaction that updates the Sapling pool and returns the new state of the pool among other things.

Let's have a look at the method signature:
```ocaml
val sapling_verify_update : 
	'a sapling_transaction -> 
	'a sapling_state -> 
	(bytes * (int * 'a sapling_state)) option
```
The method accepts 2 arguments:
- A Sapling transaction that will be verified
- A Sapling state against which the transaction is verified

> Note:
> They must both have the same `memo_size`.

It returns a value of type `option` with a tuple that contains these 3 values:
- the bound data in `bytes`
- the balance of the transaction as an `int`
- the new Sapling state

If the value is `None`, this means that the Sapling transaction is not valid in the given Sapling state. If the value is `Some tuple`, the changes have been successfully applied!

Let's set up the `main` function of the contract:
```ocaml
let main (tx_list, s : parameter * storage) : return =
	let (ops, new_state, difference) =
		List.fold
			(...)
			tx_list
			(([]: operation list), s, Tezos.get_amount ())
```
Nothing really special here, we pass the list of transactions to the `main` function and we use `List.fold` to iterate through it. The folding function will return a list of operations (in case there are unshielding transactions), the new state of the pool, and the remainder once all the balance updates have been run.

Now, we can write the code to use `Tezos.sapling_verify_update`:
```ocaml
fun (((ops, prev_state, budget), tx) : 
(operation list * storage * tez) * 8 sapling_transaction) ->
	match Tezos.sapling_verify_update tx prev_state with
	| None -> failwith \"INVALID_SAPLING_TX\"
	| Some (bound_data, (tx_balance, new_sapling_state)) ->
		let tx_balance_in_tez = 1mutez * abs tx_balance in
		(...)
```
As indicated by the accumulator of the `List.fold` method, the function receives as a parameter a tuple with another tuple on the left containing a list of operations, the Sapling state and the amount of tez sent  and on the right, the transaction from the list.

> Note: as previously mentioned, the Sapling transactions in the list must have the same memo size as the `sapling_transaction` type in the contract.

Our contract only holds one Sapling state, so this is the one we will pass around at each iteration of the loop that will change according to the transactions.

The `Tezos.sapling_verify_update` then returns a value of type `(bytes * (int * 'a sapling_state)) option`. If it is `None`, we make the whole execution of the contract fail. If it's `Some`, we destruct the tuple to get each individual value returned by the update of the Sapling pool.

We can now use these values and see what we can do with them in the next paragraphs. For convenience, we convert the `tx_balance` from `int` to `tez` now so we can use it later in our code and store the result in `tx_balance_in_tez`.

# Unshielding transactions
The first kind of transaction that we will handle in the contract is unshielding transactions. It means that a participant in the pool requested that their XTZ be taken out of the pool and transferred to an implicit account outside of the contract.

In order to know that, we will check the `int` value that we destructed from the tuple above, it represents the balance of the transaction after the transaction is applied. If that value is greater than zero, it means that the balance represents an amount that has to be sent in a new transaction.

Here is the code that will handle this part of the contract:
```ocaml
if tx_balance > 0
then
	(
		match (Bytes.unpack bound_data: key_hash option) with
		| None -> failwith \"UNABLE_TO_UNPACK_RECIPIENT\"
		| Some (recipient_key_hash) ->
			let recipient = Tezos.implicit_account recipient_key_hash in
			let op = Tezos.transaction unit tx_balance_in_tez recipient in
			(op :: ops), new_sapling_state, budget
	)            
else
	(...)
```

A couple of paragraphs above, we introduced the `bound_data`, a string of bytes returned by `Tezos.sapling_verify_update` and you may have wondered what it is. In the case when the transaction balance is greater than zero, the bytes represent the key hash of the recipient of the XTZ.

First, we have to unpack the bytes in order to get a value of type `key_hash` that we can use to forge a transaction. This is achieved with the `Bytes.unpack` method.

> Note: you must type manually the output of `Bytes.unpack` to indicate to the compiler what type of value you are expecting, in this case, `key_hash option`.

The `Bytes.unpack` method returns an optional value that we pattern match. If the value is `None`, the bytes couldn't be unpacked (they may be corrupted or just wrong) and the execution of the contract fails. If the value is `Some key_hash`, we can continue.

The next step involves creating a transfer operation. We need a value of type `unit contract` to transfer tez to an implicit account, so we cast the `key_hash` into this type of value with `Tezos.implicit_account`.

Next, we forge the operation by using `Tezos.transaction` that takes 3 parameters:
- the parameter to send with the transaction, in the case of a transfer of tez to an implicit account, it will be `unit`
- the amount to send, we can use the `tx_balance_in_tez` we created above to pass this value
- the address of the recipient of the transfer, i.e. the one we got in the line above, `recipient`

At the end of this branch, we return a list of operations to which we add the operation we just forged with `op :: ops`, the new Sapling state and the tracked amount.

# Other transactions
If the transaction balance is equal to or less than zero, the sender of the transaction is attempting one of 2 actions:
- sending tez in a shielding transaction
- sending a Sapling transaction to update the Sapling pool of the contract

Here is the code:
```ocaml
else
	(
		match (budget - tx_balance_in_tez) with
		| None -> failwith \"INVALID_AMOUNT\"
		| Some (diff) -> (
			if Bytes.length bound_data <> 0n
			then failwith \"UNEXPECTED_EMPTY_BOUND_DATA\"
			else 
				ops, new_sapling_state, diff
		)
	)
```
First, we use `tx_balance_in_tez` that we subtract from the tracked amount to check that the transaction balance returned by `Tezos.sapling_verify_update` is not greater than the amount of tez that we are tracking all the way from the initial one sent along the transaction.

For the subtraction, we use pattern matching as this will yield a value of type `tez option`. If it succeeds, we verify that the length of the bytes for the bound data is not equal to zero (that would indicate that something is wrong), then we return the list of operations, the new state and the result of the subtraction.

At this point, the iteration through the list of Sapling transactions is over. We make a last check to verify that all the tez that were sent with the initial transaction have been spent:
```ocaml
if (difference <> 0mutez)
then failwith \"UNEXPECTED_REMAINDER\"
else ops, new_state
```

And that's it! You have successfully processed a list of Sapling transactions with your Sapling contract 🥳

# Conclusion
This tutorial is a simple example of what can be achieved with a few lines of CameLigo code when you want to write a Sapling contract.

CameLigo (and the underlying Michelson) abstracts a lot of the complexities of using this amazing technology in order to provide an API simple enough that any developer with a basic knowledge of smart contract development on Tezos can start quickly prototyping or developing the next big privacy-focused dapp 🥷

A special thank you to Raphaël Cauderlier at [Nomadic Labs](https://twitter.com/LabosNomades) for writing the original Michelson contracts this tutorial and the subsequent ones are based on and for his precious help in correcting the CameLigo code!

# Links
-   Sapling documentation: [https://tezos.gitlab.io/active/sapling.html#sapling-integration](https://tezos.gitlab.io/active/sapling.html#sapling-integration)
-   Taquito Sapling library: [https://tezostaquito.io/docs/sapling/](https://tezostaquito.io/docs/sapling/)
-   Tutorial about Taquito Sapling package: [https://medium.com/ecad-labs-inc/using-sapling-with-taquito-649ccb248c95](https://medium.com/ecad-labs-inc/using-sapling-with-taquito-649ccb248c95)
- Ligo documentation: [https://ligolang.org/docs/intro/introduction?lang=cameligo](https://ligolang.org/docs/intro/introduction?lang=cameligo)"