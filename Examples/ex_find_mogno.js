db.restaurants.find(
    { "grades.score": { $gte: 30 } }, // au moins un score plus grand ou égal à 30
    { name: 1, "grades.score": 1, _id: 0 }
).limit(10);


db.restaurants.find(
    { name: { $exists: false } },
    { name: 1, "address.street": 1, _id: 0 }
).limit(5);


// Tous les restaurants qui ont déjà eu une note C
db.restaurants.find(
    { "grades.grade": "C" },
    { "grades.grade": 1, _id: 0 }
).limit(10);


// Au moins une inspection avec grade=A ET score < 5
db.restaurants.find(
    { grades: { $elemMatch: { grade: "A", score: { $lt: 5 } } } },
    { name: 1, borough: 1, cuisine: 1, _id: 0 }
).limit(10);

db.restaurants.countDocuments()


// PIÈGE CLASSIQUE : quand on a plusieurs critères à vérifier
// sur un tableau d'objets, ne PAS utiliser $elemMatch
// peut produire des faux positifs

db.etudiants.insertMany([
    {
        nom: "Alice",
        notes: [
            { matiere: "maths", note: 18 },
            { matiere: "français", note: 9 }
        ]
    },
    {
        nom: "Bob",
        notes: [
            { matiere: "maths", note: 8 },
            { matiere: "français", note: 16 }
        ]
    }
])

// ATTENTION :
// MongoDB vérifie chaque critère séparément sur le tableau.
// Il suffit qu’un élément ait matiere = "maths"
// et qu’un (autre) élément ait note > 15.
// Les deux conditions ne sont PAS garanties sur le même objet.
// Résultat : Alice ET Bob (faux positif pour Bob)
db.etudiants.find({
    "notes.matiere": "maths",
    "notes.note": { $gt: 15 }
});

// BONNE PRATIQUE :
// $elemMatch impose que TOUTES les conditions
// s'appliquent au MÊME élément du tableau "notes".
// Résultat : uniquement Alice (logique métier respectée)
db.etudiants.find({
    notes: {
        $elemMatch: {
            matiere: "maths",
            note: { $gt: 15 }
        }
    }
});

db.etudiants.find({
    notes: {
        $elemMatch: {
            matiere: "maths",
            note: { $gt: 15 }
        }
    },
    
}, {"notes.note" : 1, _id : 0}
)


db.restaurants.aggregate([
    { $group: { _id: "$cuisine", count: { $sum: 1 } } },
    { $sort: { count: -1 } },
    { $limit: 10 }
  ]);