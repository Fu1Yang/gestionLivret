       >>SOURCE FORMAT FREE
identification division.
program-id. livret-epargne.

environment division.
input-output section.
file-control.
    select transactions-file assign to "LIVRET"
        organization is line sequential
        file status is ws-file-status.

data division.
file section.
fd transactions-file.
01 transaction-record pic x(256).

working-storage section.
01 ws-file-status pic xx.
01 ws-end-of-file pic 9 value 0.
01 ws-line-number pic 9(6) value 0.
01 ws-valid-count pic 9(6) value 0.
01 ws-rejected-count pic 9(6) value 0.
01 ws-line-length binary-long.
01 ws-raw-amount pic 9(8).
01 ws-amount pic 9(6)v99.
01 ws-balance pic 9(12)v99 value 0.
01 ws-next-balance pic 9(12)v99 value 0.
01 ws-total-deposits pic 9(12)v99 value 0.
01 ws-total-withdrawals pic 9(12)v99 value 0.
01 ws-interest pic 9(12)v99 value 0.
01 ws-final-balance pic 9(12)v99 value 0.
01 ws-rate pic 9v99999 value 0.03000.
01 ws-rate-percent pic 999v999 value 3.
01 ws-rate-argument pic x(32).
01 ws-edit-amount pic z(5)9.99.
01 ws-edit-balance pic z(11)9.99.
01 ws-edit-total pic z(11)9.99.
01 ws-edit-interest pic z(11)9.99.
01 ws-edit-final pic z(11)9.99.
01 ws-edit-rate pic zz9.999.
01 ws-size-error pic 9 value 0.

procedure division.
main.
    accept ws-rate-argument from command-line
    if ws-rate-argument not = spaces
        if function test-numval(ws-rate-argument) not = 0
            or function numval(ws-rate-argument) < 0
            or function numval(ws-rate-argument) > 100
            display "ERREUR: Taux invalide (0 a 100 pour cent)."
            move 1 to return-code
            stop run
        end-if
        compute ws-rate-percent = function numval(ws-rate-argument)
        compute ws-rate = ws-rate-percent / 100
    end-if

    open input transactions-file
    if ws-file-status not = "00"
        display "ERREUR: Impossible d'ouvrir LIVRET (statut "
            ws-file-status ")."
        move 1 to return-code
        stop run
    end-if

    perform until ws-end-of-file = 1
        read transactions-file
            at end move 1 to ws-end-of-file
            not at end perform process-transaction
        end-read
        if ws-file-status not = "00" and "10"
            display "ERREUR: Lecture de LIVRET (statut "
                ws-file-status ")."
            close transactions-file
            move 1 to return-code
            stop run
        end-if
    end-perform

    close transactions-file
    if ws-file-status not = "00"
        display "ERREUR: Fermeture de LIVRET (statut "
            ws-file-status ")."
        move 1 to return-code
        stop run
    end-if

    compute ws-interest rounded = ws-balance * ws-rate
    compute ws-final-balance = ws-balance + ws-interest
        on size error
            display "ERREUR: Depassement du solde final."
            move 1 to return-code
            stop run
    end-compute
    perform show-summary
    move 0 to return-code
    stop run.

process-transaction.
    add 1 to ws-line-number
    compute ws-line-length =
        function length(function trim(transaction-record trailing))

    evaluate true
        when ws-line-length = 9
            if transaction-record(2:8) is not numeric
                perform reject-line
                exit paragraph
            end-if
            move transaction-record(2:8) to ws-raw-amount
            compute ws-amount = ws-raw-amount / 100
        when ws-line-length = 10
            if transaction-record(2:6) is not numeric
                or transaction-record(8:1) not = "."
                or transaction-record(9:2) is not numeric
                perform reject-line
                exit paragraph
            end-if
            compute ws-amount =
                function numval(transaction-record(2:9))
        when other
            perform reject-line
            exit paragraph
    end-evaluate

    if ws-amount = 0
        perform reject-line
        exit paragraph
    end-if

    evaluate transaction-record(1:1)
        when "D" perform process-deposit
        when "R" perform process-withdrawal
        when other perform reject-line
    end-evaluate.

process-deposit.
    move 0 to ws-size-error
    compute ws-next-balance = ws-balance + ws-amount
        on size error move 1 to ws-size-error
    end-compute
    if ws-size-error = 1
        perform reject-line
        exit paragraph
    end-if
    move ws-next-balance to ws-balance
    add ws-amount to ws-total-deposits
    add 1 to ws-valid-count
    move ws-amount to ws-edit-amount
    move ws-balance to ws-edit-balance
    display "DEPOT   : " function trim(ws-edit-amount)
        " EUR - Nouveau solde: " function trim(ws-edit-balance)
        " EUR".

process-withdrawal.
    if ws-amount > ws-balance
        display "RETRAIT REFUSE ligne " ws-line-number
            ": solde insuffisant."
        add 1 to ws-rejected-count
        exit paragraph
    end-if
    subtract ws-amount from ws-balance
    add ws-amount to ws-total-withdrawals
    add 1 to ws-valid-count
    move ws-amount to ws-edit-amount
    move ws-balance to ws-edit-balance
    display "RETRAIT : " function trim(ws-edit-amount)
        " EUR - Nouveau solde: " function trim(ws-edit-balance)
        " EUR".

reject-line.
    display "TRANSACTION INVALIDE ligne " ws-line-number
        ": " function trim(transaction-record trailing)
    add 1 to ws-rejected-count.

show-summary.
    move ws-balance to ws-edit-balance
    move ws-total-deposits to ws-edit-total
    move ws-rate-percent to ws-edit-rate
    display " "
    display "RESUME ANNUEL DU LIVRET"
    display "Lignes lues             : " ws-line-number
    display "Operations acceptees    : " ws-valid-count
    display "Operations rejetees     : " ws-rejected-count
    display "Total des depots        : "
        function trim(ws-edit-total) " EUR"
    move ws-total-withdrawals to ws-edit-total
    display "Total des retraits      : "
        function trim(ws-edit-total) " EUR"
    display "Solde avant interets    : "
        function trim(ws-edit-balance) " EUR"
    move ws-interest to ws-edit-interest
    display "Interets (" function trim(ws-edit-rate)
        "%)         : " function trim(ws-edit-interest) " EUR"
    move ws-final-balance to ws-edit-final
    display "Solde apres interets    : "
        function trim(ws-edit-final) " EUR".
