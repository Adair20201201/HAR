function Location = PFfilter(pre_pos, particles)

[P,E] = gauss_pdf(particles, pre_pos, 1*eye(2));

norm = 1/sum(P,2);

Location = norm*particles*P.';


