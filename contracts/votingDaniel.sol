// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.12;

import "@openzeppelin/contracts/access/Ownable.sol";

// Projet de Daniel Ventadour
contract Voting is Ownable{

    uint id;
    uint NumProposition; //  compteur de proposition, incrémenté +1 à chaque enregistrement d'une proposition
    address admin;
    bool TestisRegistered;

    struct Voter {          // c'est l'electeur avec ses attibuts
        bool isRegistered;
        bool hasVoted;
    } 

    Voter  AttributTemp;

    uint votedProposalId;

    constructor() {
        admin = msg.sender;
        /* Au lancement du contrat le vote est fermé par défaut, 
        l'admin ouvre le vote avec la fonction RegisteringVoters() */

        PhasesVotes = WorkflowStatus.VotesTallied;  
    }


    struct Proposal {      // c'est la proposition
        string description;
        uint voteCount;
} 

/* structure, elle fait le lien entre la proposition et son créateur,
pour un même ProposalId correspond on a la proposition et son créateur */

struct AttributProposal {    
    uint IdElecteur;    // Id du créateur
    address AdressElecteur;
    uint NumId;            // Numéro de la propostion
    Proposal Proposition; // description et nombre de vote de la proposition
}

struct Gagnant {    
    uint IdElecteur;    // Id du créateur
    string description;
    uint voteCount;
}

    AttributProposal ProposalTemp;
    AttributProposal TempAttributProposal;

    AttributProposal[] TabProposals;  // Tableau des propositions enregistrées
    uint LengthTabProposals;  // longueur du tableau , c'est à dire correspond au nombre de proposition enregistrées
    uint LengthTabProposants;

    // mapping des propositions en fonction de leur adresse propriétaire
    mapping(address => AttributProposal) public ListePropositions;  // chaque electeur a un Id

    AttributProposal[] TabProposants;

    // mapping des propositions en fonction de leur adresse propriétaire
    mapping(string => AttributProposal) public ListeProposants;  // chaque electeur a un Id

    mapping(address=> bool) whitelist;

    struct ELECTEUR {      // un candidat est un électeur
        uint idElecteur;
        address _address;
        Voter attribut;
    }

    // mapping des electeurs en fonction de leur adresse
    mapping(address => ELECTEUR) public ListeElecteurs;  // chaque electeur a un Id


    // Enum représentant les différentes phases du vote
    /* -Enregistrement électeur
    - enregistrement des candidats faisant une prposition (préalablement inscrits en tant qu'électeur)
    -fermeture enregistrement des candidats
    - ouverture du vote , choix de la proposition par chaque électeur, candidat y compris
    - fermeture du vote , choix de la proposition par chaque électeur, candidat y compris
    - fermeture des votes  */

    // C'est l'admin qui fixe l'état les différentes phases du vote

    enum WorkflowStatus {
        RegisteringVoters ,                  // session  Enregistrement des électeurs
        ProposalsRegistrationStarted,       /* session  Enregistrement des prosposants, c'est à dire les électeurs préalablement inscrits
                                            et se présente en candidat de proposition */
        ProposalsRegistrationEnded,         /* session  Enregistrement des prosposants Terminée */

        VotingSessionStarted,               // Session de vote est ouverte

        VotingSessionEnded,                 // Session de vote est terminée
        VotesTallied                        // Election terminée
    }

    

    WorkflowStatus public PhasesVotes;

    event VoterRegistered(address voterAddress); 
    event WorkflowStatusChange(WorkflowStatus previousStatus, WorkflowStatus newStatus);

    event ProposalRegistered(uint proposalId);

    event Voted (address voter, uint proposalId);

    
    function RegisteringVoters() public  onlyOwner  { PhasesVotes = WorkflowStatus.RegisteringVoters; }
    function ProRegStarted() public  onlyOwner  { PhasesVotes = WorkflowStatus.ProposalsRegistrationStarted; }
    function ProRegEnded() public onlyOwner   { PhasesVotes = WorkflowStatus.ProposalsRegistrationEnded; }
    function VotSesStarted() public  onlyOwner  { PhasesVotes = WorkflowStatus.VotingSessionStarted; }
    function VotSesEnded() public  onlyOwner  { PhasesVotes = WorkflowStatus.VotingSessionEnded; }
    function VotesTallied () public  onlyOwner  { PhasesVotes = WorkflowStatus.VotesTallied ; }


    //    mapping(address=> addressStatus) list;
        event Authorized(address _address); // Event
        event Blacklisted(address _address); // Event


    // ENREGISTREMENT DES ELECTEURS        // ENREGISTREMENT DES CANDIDATS  ATTENTION METTRE onlyowner
    //Fonction d'enregistrement d'un électeur    //Fonction d'enregistrement d'un candidat
    function enregisterElecteur (address  _Adresselecteur) public  onlyOwner  {   // function enregisterCandidat (string memory _nom) public 
    //    require (msg.sender == admin, " tu n'es pas admin");
        require (PhasesVotes == WorkflowStatus.RegisteringVoters, " Enregistrement des electeurs non ouvert");
        require (_Adresselecteur != admin, " admin n'a pas le droit enregister");   /* seul l'admin peut ajouter des candidats autrement  pas accès au mapping candidats */
        whitelist[_Adresselecteur] = true;
        id+=1;
        

        AttributTemp.isRegistered = true;
        ListeElecteurs[_Adresselecteur]= ELECTEUR(id, _Adresselecteur, AttributTemp);       // emit Enregistrer(msg.sender, _nom);  // chaque candidat enregistré fait l'objet d'un event
        emit VoterRegistered(_Adresselecteur); 
    }

    //SHOW fonction de test d'attribut autoappentissage
    function ShowStatutElecteur (address  _Adresselecteur) public view returns (bool)
    {   // function enregisterCandidat (string memory _nom) public 

        return (ListeElecteurs[_Adresselecteur].attribut.isRegistered); 

    }

    // Enregistrement proposant (sa proposition)
    function enregisterProposant(address _Adresselecteur, string memory Proposition) public  onlyOwner {   
        require (msg.sender == admin, " tu n'es pas admin"); /* seul l'admin peut ajouter des candidats autrement  pas accès au mapping candidats */
        require (PhasesVotes == WorkflowStatus.ProposalsRegistrationStarted, "Enregistrement proposition impossible");
        require (_Adresselecteur != admin, " admin n'a pas le droit enregister sa proposition");   
        require (whitelist[_Adresselecteur] == true, "il faut d'abord etre electeur");
        ListeProposants[Proposition].Proposition.description = Proposition;
        ListeProposants[Proposition].Proposition.voteCount = 0;
        ListeProposants[Proposition].IdElecteur = ListeElecteurs[_Adresselecteur].idElecteur;

        // ListeProposants[Proposition].AdressElecteur = _Adresselecteur; //  proposition x <--> adresse de electeur x

        TempAttributProposal = ListeProposants[Proposition];

        ListeProposants[Proposition].NumId = NumProposition;

        TabProposants.push( TempAttributProposal);

        emit ProposalRegistered(NumProposition);
        NumProposition+=1;

        LengthTabProposants = TabProposants.length;
    }

    function CampagneDeVote(string memory Proposition) public {
        // candidat doit être inscrit
        // c'est admin qui autorise les votes avec l'évènement

        require (PhasesVotes == WorkflowStatus.VotingSessionStarted, "Vote proposition impossible");
        ListeProposants[Proposition].Proposition.voteCount += 1;

        TabProposants[ListeProposants[Proposition].NumId].Proposition.voteCount += 1;

        // emit (msg.sender, ListeProposants[Proposition].NumId);
    }


    //SHOW longueur TabProposas.length
    function LengthTab () public view returns (uint, string memory)
    {   // function enregisterCandidat (string memory _nom) public 

        return (TabProposants.length, TabProposants[TabProposants.length - 1 ].Proposition.description);

    }



    // ---------------------------------------------------------------------------------
    function  getWinner()  public view returns (Gagnant memory)
    { 

        require (PhasesVotes == WorkflowStatus.VotingSessionEnded, " Resultat non disponible");

    // IL FAUT RECUPERER LA LISTE, ListeProposants[Proposition].Proposition.voteCount += 1; DES PROPOSITIONS INCREMENTEES ICI 

        uint longueur = TabProposants.length;
    //     string memory _index;
        uint IdElecteur;
        string memory PropositionGagnante;
        uint TempNbredePointsMax;
        AttributProposal [] memory TabProposantsCopie = new AttributProposal[] (longueur);
        Gagnant memory _Gagnant;
    //  --------------------------------------------------------------------------------
    // TempNbredePointsMax = TabProposants[0].Proposition.voteCount;
    
    uint PosTemp;

    // copie du tableau

        for (uint i = 0 ; i < longueur ; i++) {
            TabProposantsCopie[i].Proposition.description = TabProposants[i].Proposition.description;
            TabProposantsCopie[i].Proposition.voteCount = TabProposants[i].IdElecteur;
            TabProposantsCopie[i].Proposition.voteCount = TabProposants[i].Proposition.voteCount;
            //  _index = TabProposantsCopie[i].Proposition.description;
        }

        TempNbredePointsMax =  TabProposantsCopie[0].Proposition.voteCount;
        IdElecteur =  TabProposantsCopie[0].IdElecteur;
        PropositionGagnante =  TabProposantsCopie[0].Proposition.description;
        PosTemp = 0;

        // Recherche du Gagnant

        for (uint i = 0 ; i < longueur ; i++) {
        //  PosTemp = i+1;
            if (TempNbredePointsMax <=  TabProposantsCopie[i].Proposition.voteCount){
                TempNbredePointsMax =  TabProposantsCopie[i].Proposition.voteCount; 
                PropositionGagnante =  TabProposantsCopie[i].Proposition.description;
                IdElecteur =  TabProposantsCopie[i].IdElecteur;
            }     
        }

        _Gagnant.IdElecteur =  ListeProposants[PropositionGagnante].IdElecteur;
        
        _Gagnant.description = PropositionGagnante;
        _Gagnant.voteCount = TempNbredePointsMax;

        return _Gagnant  ;

    }

}
