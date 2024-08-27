use homework6;


select  * from  user;
select  * from  post;
select  * from  post_liked_user;
select  * from  post where id = '979255b9-84a0-4180-83bd-2ea9f8925aab';
select  * from  user where email = 'dr.oleg-kozak2019@yandex.by';
select  * from  post_liked_user where postId = 'ab7f79dc-03c4-4037-b232-1cfc3b46075f';
DELETE FROM user
WHERE email = 'dr.oleg-kozak2019@yandex.by';

delete from  post where  authorLoginEmail = 'dr.oleg-kozak2019@yandex.by';

SELECT
        u.email AS user_email,
        u.firstName AS user_firstName,
        u.lastName AS user_lastName,
        p.title AS post_title,
        COUNT(plu.postId) AS likes_count
    FROM
        User u
    LEFT JOIN (
        SELECT
            authorLoginEmail,
            MIN(createDate) AS firstPostDate
        FROM
            Post
        GROUP BY
            authorLoginEmail
    ) AS first_posts ON u.email = first_posts.authorLoginEmail
    LEFT JOIN Post p ON u.email = p.authorLoginEmail AND p.createDate = first_posts.firstPostDate
    LEFT JOIN post_liked_user plu ON p.id = plu.postId
    WHERE
        p.id IS NOT NULL
    GROUP BY
        u.email, u.firstName, u.lastName, p.title;
