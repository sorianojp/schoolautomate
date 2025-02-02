<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<style type="text/css">
<!--
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}

td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}
    TABLE.thinborder {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;	
    }

    TABLE.thinborderall {
    border: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;	
    }

    TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }

    TD.thinborderGrade {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
    }
-->
</style>
</head>
<body>
<%@ page language="java" import="utility.*,java.util.Vector,enrollment.ApplicationMgmt " %>
<%
	DBOperation dbOP = null;
	WebInterface WI  = new WebInterface(request);
	Vector vExamIndex = new Vector();	
	Vector vMasterList = null;
	Vector vExamList = null;
	String strErrMsg  = null;
	String strTemp    = null;
	String astrSemester[] = {" Summer "," First Semester "," Second Semester "," Third Semester "};	
	String strSchCode = WI.getStrValue((String)request.getSession(false).getAttribute("school_code"));
	
	boolean bolIsAUF = strSchCode.startsWith("AUF");//there are few changes in the form for AUF.. 
	
	int iSearch = 0;	
	int iMaxStudPerPage = Integer.parseInt(WI.fillTextValue("num_stud_page"));
	int u = 0;
	
	if (strSchCode.startsWith("UI"))
		u = 3;
	
	
	int iNumStud = 1;
	boolean bolPageBreak = false;
	
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Admission Maintenance-ENTRANCE EXAM/INTERVIEW","exam_sched.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Admission Maintenance","ENTRANCE EXAM/INTERVIEW",request.getRemoteAddr(),
														"exam_sched.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../commfile/unauthorized_page.jsp");
	return;
}//end of authenticaion code.
	
	ApplicationMgmt appMgmt = new ApplicationMgmt();
	
	if(!strSchCode.startsWith("CGH")) {
		vExamList = appMgmt.operateOnMasterList(dbOP,request,1);
		if(vExamList == null)
			strErrMsg = appMgmt.getErrMsg();
	}
	else	
		vExamList = new Vector();

	vMasterList = appMgmt.operateOnMasterList(dbOP,request,2);
	if(vMasterList == null)
		strErrMsg = appMgmt.getErrMsg();
		
	if(vMasterList != null){
	for (;u < vMasterList.size();){%>		
		
  
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr> 
    <td height="25" colspan="5"><div align="center"> 
        <p><%=SchoolInformation.getSchoolName(dbOP,true,false)%><br>
          <%=SchoolInformation.getAddressLine1(dbOP,false,false)%></p>
<% if (strSchCode.startsWith("UI")) {%>
        <font size="2"> UNIVERSITY OF ILOILO<br>
        Testing Service<br>
        AY 2006 - 2007<br>
        Master List<br>
        </font> 
<%}%>		
		</div></td>
  </tr>
  <tr> 
    <td height="10" colspan="3">&nbsp;</td>
  </tr></tr>
  <tr> 
    <td height="25">&nbsp;&nbsp; School Year / Term: <%=WI.fillTextValue("sy_from")%> - <%=WI.fillTextValue("sy_to")%> / <%=astrSemester[Integer.parseInt(WI.fillTextValue("semester"))]%></td>
  </tr>
  <tr> 
    
  <td height="25">&nbsp;&nbsp; Master List For: 
    <%if(vExamList != null){
	  		for(int iLoop = 0;iLoop < vExamList.size();iLoop += 2){
				if(WI.fillTextValue("subject_"+(iLoop+2)/2).length() > 0){%>
					<%=" [ "+(String)vExamList.elementAt(iLoop+1)+" ] "%>					
		  <%}}}%>		
	</td>
  </tr>
  <tr> 
    <td height="25">&nbsp;&nbsp; Date of Exam: <%=WI.getStrValue(WI.fillTextValue("exam_date_fr"),"-")%> <%=WI.getStrValue(WI.fillTextValue("exam_date_to"),"- ","","")%> </td>
  </tr>
  <tr> 
    <td height="10" colspan="3">&nbsp;</td>
  </tr>
  </table>
 <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
 	 <tr bgcolor="#FFFFFF"> 
          <td height="23"><div align="center"><strong><font size="1">LIST 
              OF APPLICANTS</font></strong></div></td>
        </tr>
 </table>
	<table width="100%"  class="thinborder" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
       
        <tr> 
          <td width="7%" rowspan="2" class="thinborder"><div align="center"><strong><font size="1">NO.</font></strong></div></td>
          <td width="7%" rowspan="2" class="thinborder"><div align="center"><strong><font size="1">ID</font></strong></div></td>
          <td width="40%" rowspan="2" class="thinborder"><div align="center"><strong><font size="1">NAME</font></strong></div></td>
          <td width="7%" rowspan="2" class="thinborder"><div align="center"><strong><font size="1">SEX</font></strong></div></td>
		  <td width="7%" rowspan="2" class="thinborder"><div align="center"><strong><font size="1">PREV 
        SCHOOL</font></strong></div></td>
		  <%if(WI.fillTextValue("show_college").length() > 0){%>
              	<td width="67" rowspan="2" align="center" class="thinborder"><strong><font size="1">COLLEGE</font></strong></td>
              <%}%>
          <td width="7%" rowspan="2" class="thinborder"><div align="center"><strong><font size="1">COURSE</font></strong></div></td>
          <td width="7%" rowspan="2" class="thinborder"><div align="center"><strong><font size="1">
			<%if(bolIsAUF){%>
				DATE OF EXAM
			<%}else{%>
				DATE TAKEN 
			<%}%>
			</font></strong></div></td>
          <%if(bolIsAUF)
				vExamList = null;
			  if(vExamList != null){
			  for(int iLoop = 0;iLoop < vExamList.size();iLoop += 2){
				if(WI.fillTextValue("subject_"+(iLoop+2)/2).length() > 0){
				    vExamIndex.addElement((String)vExamList.elementAt(iLoop));%>
          <td height="25" colspan="2" class="thinborder"><div align="center"> 
              <strong><font size="1"><%=(String)vExamList.elementAt(iLoop+1)%></font></strong></div></td>
          <%}}}%>
        </tr>
        <tr> 
          <%
			  if(vExamList != null){
			  for(int iLoop = 0;iLoop < vExamList.size();iLoop += 2){
				if(WI.fillTextValue("subject_"+(iLoop+2)/2).length() > 0){%>
          <td height="25" class="thinborder"><div align="center"><strong><font size="1">SCORE</font></strong></div></td>
          <td class="thinborder"><div align="center"><strong><font size="1">SUBJECT 
              TO TAKE</font></strong></div></td>
          <%}}}%>
        </tr>
		
		<%for(int iCount2 = 0; iCount2 <= iMaxStudPerPage; u += 13,++iNumStud,iCount2++){
		if (iCount2 >= iMaxStudPerPage || u >= vMasterList.size()){
			if(u >= vMasterList.size())
				bolPageBreak = false;	
			else
				bolPageBreak = true;
			break;
		}
		%>		
        <tr> 
          <td class="thinborder"  height="25"><div align="center"><%=iNumStud%></div></td>
          <td class="thinborder"><div align="center"><%=(String)vMasterList.elementAt(u)%></div></td>
          <td class="thinborder"><div align="left">&nbsp;<%=WI.formatName((String)vMasterList.elementAt(u+1),(String)vMasterList.elementAt(u+2),(String)vMasterList.elementAt(u+3),4)%> </div></td>
          <td class="thinborder"><div align="center"><%=(String)vMasterList.elementAt(u+4)%></div></td>
		  <td class="thinborder"><div align="center"><%=WI.getStrValue((String)vMasterList.elementAt(u+11),"&nbsp;")%></div></td>
		  <%if(WI.fillTextValue("show_college").length() > 0){%><td class="thinborder"><%=WI.getStrValue((String)vMasterList.elementAt(u+12),"&nbsp;")%></td><%}%>
          <td class="thinborder"><%=WI.getStrValue((String)vMasterList.elementAt(u+10),"&nbsp;")%></td>
          <td class="thinborder"><div align="center"><%=(String)vMasterList.elementAt(u+5)%> 
              <%
				for(int v = u; (v + 13) < vMasterList.size() ;){
				 if(((String)vMasterList.elementAt(v)).compareTo((String)vMasterList.elementAt(v + 13)) != 0)
						break;%>
              <br>
              <%=(String)vMasterList.elementAt(v + 13 + 5)%> 
              <%v += 13;}%>
            </div></td>
          <%
			  if(vExamList != null){
			  int iCount = 0;
			  for(int iLoop = 0;iLoop < vExamList.size();iLoop += 2){
				if(WI.fillTextValue("subject_"+(iLoop+2)/2).length() > 0){
				    iCount++;					
			   if(u < vMasterList.size()){
			  		if(((String)vExamIndex.elementAt(iCount-1)).equals((String)vMasterList.elementAt(u+6))){%>
          <td width="193" class="thinborder"><div align="center"> <%=WI.getStrValue((String)vMasterList.elementAt(u+9),"0")%></div></td>
          <td width="166" class="thinborder"><div align="center"> 
              <%if(Integer.parseInt(WI.getStrValue((String)vMasterList.elementAt(u+9),"0")) < Integer.parseInt((String)vMasterList.elementAt(u+8)))
			  		strTemp = "+";			  
			    else
			    	strTemp = "1";
			  %>
              <%=strTemp%></div></td>
          <%if(u+13 < vMasterList.size()){
			   		if(((String)vMasterList.elementAt(u)).compareTo((String)vMasterList.elementAt(u + 13)) == 0)
			   			u+=13;
			     } 
			   }else{%>
          <td width="193" class="thinborder"><div align="center">&nbsp;</div></td>
          <td width="166" class="thinborder"><div align="center">&nbsp;</div></td
			   >
          <%}}}}}%>
        </tr>
        <%} %>
   </table>	
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">	        
<%	if (u >= vMasterList.size()-1){%>
  <tr> 
    <td><div align="center"> ***************** 
        NOTHING FOLLOWS *******************</div></td>
  </tr>
  <%}else{// end iNumStud >= vRetResult.size()%>
  <tr> 
    <td><div align="center"> ************** CONTINUED ON NEXT 
        PAGE ****************</div></td>
  </tr>
  <%}//end else%>
</table>
<% //INSERT PAGE BREAK ONLY IF IT IS NOT LAST PAGE. -- TO AVOID BLANK PAGE AT THE END. 
if (bolPageBreak) {%>
	<DIV style="page-break-before:always" >&nbsp;</DIV>
<%}//page break only if it is not last page.
 } // end for loop %>
 
 
 <% if (strSchCode.startsWith("UI") && vMasterList.size() > 3) { 
 	// force print in new page.. 
 %>
	 <DIV style="page-break-before:always" >&nbsp;</DIV>
 <%
	int iRowTotal = 0; 

	Vector vTemp = 	(Vector)vMasterList.elementAt(0);
    int k = 0;	
	
	%>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable2">	
	<tr>
		<td><div align="center"> 
        <p><%=SchoolInformation.getSchoolName(dbOP,true,false)%><br>
          <%=SchoolInformation.getAddressLine1(dbOP,false,false)%></p>
<% if (strSchCode.startsWith("UI")) {%>
        <font size="2"> UNIVERSITY OF ILOILO<br>
        Testing Service<br>
        AY 2006 - 2007<br>
        Master List<br>
        </font> 
<%}%>		
		</div>  </td>
	</tr>
	<tr>
		<td>&nbsp;</td>
	</tr>	
	<tr>
		<td>
<% 
	 if (vTemp != null && vTemp.size() > 0) {
		  vExamList = (Vector)vTemp.elementAt(0);
		  int[] iColTotal = new int[vExamList.size()*2];
		  
		  for (k = 0; k < vExamList.size()*2; k++)
		  	iColTotal[k] = 0;
	 %>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable2">
  <tr>
  	<td colspan="3" align="center">
		Detailed information of number of applicants who passed or failed in the Placement Test    </td>
  </tr>
  </table>	 
  <table width="85%" border="0" align="center" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder" id="myADTable2">
   
  <tr>
  	<td width="20%" rowspan="2" align="center" class="thinborder"><strong>COURSE</strong></td>
	<% for (k = 0; k < vExamList.size(); k++){%> 
    <td colspan="2" align="center" class="thinborder"><%=(String)vExamList.elementAt(k)%></td>
	<%}%>
   </tr>
  <tr>
    <% for (k = 0; k < vExamList.size(); k++){%> 	
    <td width="10%" align="center" class="thinborder">Passed</td>
    <td width="10%" align="center" class="thinborder">Failed</td>
	<%}%> 
  </tr>
  <% String strCourse =null;
  	for (int i = 1; i < vTemp.size();) {
	
	  	strCourse = (String)vTemp.elementAt(i);
		
	
  %>
  <tr>
    <td align="center" class="thinborder"><%=strCourse%></td>
	<% for (k=0; k < vExamList.size(); k++){
	
		if (((String)vTemp.elementAt(i+2)).equals((String)vExamList.elementAt(k)) && 
			((String)vTemp.elementAt(i+3)).equals("0")){  // passs
			
			strTemp = (String)vTemp.elementAt(i+4);
			iColTotal[2*k] += Integer.parseInt(strTemp);

			i+=5;			
		}else{
			strTemp = "0";
		}
		
		%> 
	    <td align="center" class="thinborder">&nbsp;<%=strTemp%></td>
		<%
			if ( i < vTemp.size() &&
				strCourse.equals((String)vTemp.elementAt(i)) && 
				((String)vTemp.elementAt(i+2)).equals((String)vExamList.elementAt(k)) && 
				((String)vTemp.elementAt(i+3)).equals("1")){  // 1
				
				strTemp = (String)vTemp.elementAt(i+4);
				iColTotal[2*k+1] += Integer.parseInt(strTemp);				
				i+=5;			
			}else{
				strTemp = "0";
			}
		%>			
	    <td align="center" class="thinborder">&nbsp;<%=strTemp%></td>
	<%}%> 
  </tr>
  <%}%>
  <tr>
    <td align="center" class="thinborder"><strong>Subtotal</strong></td>
	<% for (k=0; k < vExamList.size(); k++){ %> 
	    <td align="center" class="thinborder">&nbsp;<%=iColTotal[2*k]%></td>
	    <td align="center" class="thinborder">&nbsp;<%=iColTotal[2*k+1]%></td>
	<%}%> 
  </tr>
  </table>  </td>
	</tr>
	<tr>
	  <td>&nbsp;</td>
    </tr>
	<tr>
	  <td align="center"><strong>::: SUMMARY :::</strong> </td>
    </tr>
	<tr>
	  <td align="center">&nbsp;</td>
    </tr>
	<tr>
	  <td align="center">
		<table width="60%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">

  	<% for (k = 0; k < vExamList.size(); k++){%>    
  <tr>

    <td width="40%" rowspan="2" align="center" class="thinborder">
				<%=(String)vExamList.elementAt(k)%>	</td>

    <td width="30%" align="center" class="thinborder">Passed</td>
    <td width="30%" align="center" class="thinborder"><%=iColTotal[2*k]%></td>
  </tr>
  <tr>
    <td align="center" class="thinborder">Failed</td>
    <td align="center" class="thinborder"><%=iColTotal[2*k+1]%></td>
  </tr>
   	<%}%>
	  </table>	  </td>
    </tr>
	<tr>
	  <td align="center">&nbsp;</td>
    </tr>
  <% strCourse =null;
  	vTemp =  (Vector)vMasterList.elementAt(1);
	
	iColTotal[0] = 0;
	iColTotal[1] = 0; 
	
	
	if (vTemp != null && vTemp.size() > 0) {
  %>	
	<tr>
	  <td align="center"><!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
      <p class="style1">Summary  	of Male / Female Applicants</p></td>
    </tr>
	<tr>
	  <td align="center">
	  
	  <table width="85%" border="0" align="center" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
        <tr>
          <td width="20%" rowspan="2" align="center" class="thinborder"><strong>Course</strong></td>
          <td colspan="2" align="center" class="thinborder">Gender</td>
          <td width="10%" rowspan="2" align="center" class="thinborder">Total</td>
        </tr>
        <tr>
          <td width="10%" align="center" class="thinborder">Male</td>
          <td width="10%" align="center" class="thinborder">Female</td>
        </tr>
<%
	
  	for (int i = 0; i < vTemp.size();i+=3) {
	  	strCourse = (String)vTemp.elementAt(i);
		iRowTotal = 0;
  %>
        <tr>
          <td align="center" class="thinborder"><%=strCourse%></td>
         <%
	
		if (((String)vTemp.elementAt(i+1)).equals("M"))
		{  // MALE, 
			
			strTemp = (String)vTemp.elementAt(i+2);
			iColTotal[0] += Integer.parseInt(strTemp);
			iRowTotal = Integer.parseInt(strTemp);
			i+=3;			
		}else{
			strTemp = "0";
		}
		
		%>
          <td align="center" class="thinborder">&nbsp;<%=strTemp%></td>
          <%
			if ( i < vTemp.size() &&
				strCourse.equals((String)vTemp.elementAt(i)) && 
				((String)vTemp.elementAt(i+1)).equals("F")){  // 1
				
				strTemp = (String)vTemp.elementAt(i+2);
				iRowTotal += Integer.parseInt(strTemp);
				iColTotal[1] += Integer.parseInt(strTemp);				
			}else{
				strTemp = "0";
			}
		%>
          <td align="center" class="thinborder">&nbsp;<%=strTemp%></td>
          <td align="center" class="thinborder">&nbsp;<%=iRowTotal%></td>
        </tr>
        <%}%>
        <tr>
          <td align="right" class="thinborder">TOTAL&nbsp;&nbsp;</td>
          <td align="center" class="thinborder"><%=iColTotal[0]%></td>
          <td align="center" class="thinborder"><%=iColTotal[1]%></td>
          <td align="center" class="thinborder"><%=iColTotal[0] + iColTotal[1]%></td>
        </tr>		
      </table></td>
    </tr>
	<%
	  } // if vtemp.size() > 0 ... summary of course applicant per gender.. 
	%> 
	<tr>
	  <td align="center">&nbsp;</td>
    </tr>
	
  <% strCourse =null;
  	vTemp =  (Vector)vMasterList.elementAt(2);
	
	  for (k = 0; k < vExamList.size()*2; k++)
		iColTotal[k] = 0;	
	
	
	%>
	
	<tr>
	  <td align="center"><p class="style1">Summary of number of male / female  applicants who passed / failed in the Placement Test</p></td>
    </tr>
	<tr>
	  <td align="center"><table width="85%" border="0" align="center" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
        <tr>
          <td width="20%" rowspan="2" align="center" class="thinborder"><strong>Gender</strong></td>
			<% for (k = 0; k < vExamList.size(); k++){%> 
			    <td colspan="2" align="center" class="thinborder">
						<%=(String)vExamList.elementAt(k)%>
				</td>
		  <%}%>
          </tr>
        <tr>
	<% for (k = 0; k < vExamList.size(); k++){%> 
          <td width="10%" align="center" class="thinborder">Passed </td>
          <td width="10%" align="center" class="thinborder">Failed </td>
	  <%}%>
        </tr>
        <%
	
  	for (int i = 0; i < vTemp.size();i+=4) {
	  	strCourse = (String)vTemp.elementAt(i);
		
		if (strCourse.equals("M")) 
			strTemp = "Male";
		else
			strTemp = "Female";
		
		iRowTotal = 0;
  %>
        <tr>
          <td align="center" class="thinborder"><%=strTemp%></td>
	<% for (k=0; k < vExamList.size(); k++){
	
		if (((String)vTemp.elementAt(i+1)).equals((String)vExamList.elementAt(k)) && 
			((String)vTemp.elementAt(i+2)).equals("0")){  // passs
			
			strTemp = (String)vTemp.elementAt(i+3);
			iColTotal[2*k] += Integer.parseInt(strTemp);

			i+=4;			
		}else{
			strTemp = "0";
		}
		
		%> 
	    <td align="center" class="thinborder">&nbsp;<%=strTemp%></td>
		<%
			if ( i < vTemp.size() &&
				strCourse.equals((String)vTemp.elementAt(i)) && 
				((String)vTemp.elementAt(i+1)).equals((String)vExamList.elementAt(k)) && 
				((String)vTemp.elementAt(i+2)).equals("1")){  // 1
				
				strTemp = (String)vTemp.elementAt(i+3);
				iColTotal[2*k+1] += Integer.parseInt(strTemp);				
				i+=4;			
			}else{
				strTemp = "0";
			}
		%>			
	    <td align="center" class="thinborder">&nbsp;<%=strTemp%></td>
			<%}%> 
	
	      </tr>
        <%}%>
        <tr>
          <td align="right" class="thinborder">TOTAL&nbsp;&nbsp;</td>
	<% for (k=0; k < vExamList.size(); k++){ %> 
		    <td align="center" class="thinborder">&nbsp;<%=iColTotal[2*k]%></td>
		    <td align="center" class="thinborder">&nbsp;<%=iColTotal[2*k+1]%></td>
	<%}%> 
          </tr>
      </table></td>
    </tr>
	<tr>
	  <td align="center">&nbsp;</td>
    </tr>
  <% } // end vTemp != null  %>		
 </table>
  <%  } // specific for UI Reports only..  %>
 
 
 
 
 
 
<% }//end first else  vMasterList != null%>
<script language="JavaScript">
	window.print();
</script>
</body>
</html>
<% dbOP.cleanUP(); %>