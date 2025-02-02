<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Book Distribution per Course</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../../css/reportlink.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">

//call this if course type is changed from regular course to summer course or internship course
function copyCurYr(strCYFrom, strCYTo) {
	document.form_.cy_from.value = strCYFrom;
	document.form_.cy_to.value   = strCYTo;
	this.ReloadPage();	
}

function ReloadPage()
{
	document.form_.submit();
}

function printPg() {
	
 	document.bgColor = "#FFFFFF";
	   	
	document.getElementById('myTableAD1').deleteRow(0);
	
	var obj = document.getElementById('myTableAD2');
	obj.deleteRow(0);
	obj.deleteRow(0);
	obj.deleteRow(0);
	obj.deleteRow(0);
	obj.deleteRow(0);
	obj.deleteRow(0);
	obj.deleteRow(0);
	
	document.getElementById('myTableAD3').deleteRow(0);
	document.getElementById('myTableAD3').deleteRow(0);
	
	alert("Click OK to print this page");
	window.print();//called to remove rows, make bg white and call print.
}

</script>
<body>

<%@ page language="java" import="utility.*,lms.CatalogReport,java.util.Vector, java.util.Date" %>
<% 		
	String strTitle 		= "TITLE";
	String strAuthor 		= "AUTHOR";
	String strYearPrinted 	= "YEAR PRINTED";
	String strQty 			= "QTY";
	
	String[] strYearLevel 	= {" ","FIRST YEAR","SECOND YEAR","THIRD YEAR","FOURTH YEAR"};
	String[] strSemester 	= {" ","FIRST SEMESTER","SECOND SEMESTER"};	
	
	String strTempYear=strYearLevel[0];
	String strTempSem=strSemester[0];	
	boolean bolIsFirstPage 	= true;	
	int lineCtr=0;	
	int iCtr=0;
%>
<%
	DBOperation dbOP  = null;
	String strErrMsg  = null;
	String strTemp    = null;

	WebInterface WI   = new WebInterface(request);
	Vector vRetResult = new Vector();//this is added to store the subject descirption, category name and category index for Pre-requisite
	
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"LIB_Cataloging-Reports-Book Distribution Per Course","book_distribution_per_course.jsp");
		//dbOP = new DBOperation();
								
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}
//authenticate this user.

CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"LIB_Cataloging","REPORTS",request.getRemoteAddr(),
												"card_print_info.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../lms/");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authentication code.

    //[0] course_code, [1] course_name, [2] major_code, [3] major_name
    Vector vCourseInfo  = new Vector();
    //[0] sub_index, [1] book_title, [2] author_name, [3] number of books.
    Vector vSubBookInfo = new Vector();
    //[0] year, [1] semester, [2] sub_index, [3] sub_code, [4] sub_name
    Vector vCurInfo     = new Vector();  
	
	CatalogReport CR = new CatalogReport();
	int iIndexOf = 0;
	Long lIndex = null;
	
	String prevYear = null;		
	String prevSem = null;	
	
	
	if(WI.fillTextValue("course_index").length() > 0 && WI.fillTextValue("cy_from").length() > 0 ) {
		vRetResult = CR.getBookDistributionPerCourse(dbOP, request);
		if(vRetResult == null) 
			strErrMsg = CR.getErrMsg();
		else {
			vCourseInfo  = (Vector)vRetResult.remove(0);
		    vSubBookInfo = (Vector)vRetResult.remove(0);
		    vCurInfo     = (Vector)vRetResult.remove(0);  
		}
	}
	
	
%>

<form name="form_" method="post" action="./book_distribution_per_course.jsp">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" id="myTableAD1">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="4" class="thinborderBOTTOM"><div align="center"><strong>::::
          BOOK DISTRIBUTION PER COURSE ::::</strong></div></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  id="myTableAD2">
    <tr> 
      <td width="2%" >&nbsp;</td>
      <td height="25" colspan="2"><b><font size="3" color="#FF0000"><%=WI.getStrValue(strErrMsg,"Message: ","","")%></font></b> </td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td>Publisher Date: 
	  	<input name="publisher_date" type="text" size="5" maxlength="5" value="<%=WI.fillTextValue("publisher_date")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyInteger('form_','cy_from');style.backgroundColor='white'"
	  onKeyUP="AllowOnlyInteger('form_','publisher_date')">
		</td>
      <td>&nbsp;</td>
    </tr>
    
    <tr> 
      <td width="2%">&nbsp;</td>
      <td>College 
		 <select name="c_index" onChange="document.form_.cy_from.value='';document.form_.cy_to.value='';document.form_.submit();">
        <option value="">Select Any</option>
        <%=dbOP.loadCombo("c_index","c_name"," from college where IS_DEL=0 order by c_name", request.getParameter("c_index"), false)%>
      </select>
		 
		 </td>
      <td width="30%">Curriculum year </td>
    </tr></tr>
    <tr> 
      <td height="25">&nbsp;</td>
		<%
		strTemp = " from course_offered where IS_DEL=0 and is_valid=1 and is_offered = 1 and degree_type=0 ";
		if(WI.fillTextValue("c_index").length() > 0)
			strTemp += " and c_index = "+WI.fillTextValue("c_index");
		strTemp += " order by course_name asc";
		%>
      <td>
		Course
			<select name="course_index" onChange="document.form_.cy_from.value='';document.form_.cy_to.value='';document.form_.submit();">
        <option value="">Select Any</option>
        <%=dbOP.loadCombo("course_index","course_name", strTemp, request.getParameter("course_index"), false)%>
      </select></td>
      <td><input name="cy_from" type="text" size="5" maxlength="5" value="<%=WI.fillTextValue("cy_from")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyInteger('form_','cy_from');style.backgroundColor='white'"
	  onKeyUP="AllowOnlyInteger('form_','cy_from')" readonly="yes">
        to 
        <input name="cy_to" type="text" size="5" maxlength="5" value="<%=WI.fillTextValue("cy_to")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyInteger('form_','cy_to');style.backgroundColor='white'"
	  onKeyUP="AllowOnlyInteger('form_','cy_to')" readonly="yes" o>	 </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td valign="top">Major&nbsp;&nbsp; <select name="major_index" 
	  		onChange="document.form_.cy_from.value='';document.form_.cy_to.value='';document.form_.submit();" >
          <option></option>
          <%
strTemp = WI.fillTextValue("course_index");
if(strTemp.length() > 0)
{
strTemp = " from major where is_del=0 and course_index="+strTemp ;
%>
          <%=dbOP.loadCombo("major_index","major_name",strTemp, request.getParameter("major_index"), false)%> 
          <%}%>
        </select> </td>
      <td>
<%
Vector vCurYearInfo = null;
strTemp = null;
if(WI.fillTextValue("course_index").length() == 0 || WI.fillTextValue("course_index").compareTo("selany") == 0) 
	strTemp = null;
else	
	strTemp = WI.fillTextValue("major_index");

vCurYearInfo = new enrollment.SubjectSection().getSchYear(dbOP, request.getParameter("course_index"),strTemp);
if(vCurYearInfo != null) {
%>	  
	  <strong><font color="#0000FF" size="1">Existing Cur Year:</font> </strong><br>
	  	
		<%
		for(int i = 0; i < vCurYearInfo.size(); i += 2) {%>
			<a href="javascript:copyCurYr(<%=(String)vCurYearInfo.elementAt(i)%>,<%=(String)vCurYearInfo.elementAt(i + 1)%>);">
			<font size="1" color="#000099">(<%=(String)vCurYearInfo.elementAt(i) + " - " +(String)vCurYearInfo.elementAt(i + 1)%>)</font></a>
		<%i = i + 2;
		if(i < vCurYearInfo.size()){%>
			<a href="javascript:copyCurYr(<%=(String)vCurYearInfo.elementAt(i)%>,<%=(String)vCurYearInfo.elementAt(i + 1)%>);">
			<font size="1" color="#000099">(<%=(String)vCurYearInfo.elementAt(i) + " - " +(String)vCurYearInfo.elementAt(i + 1)%>)</font></a>
		<%}//show two in one line.%>
		<br>
		<%}%>
		
<%}//only if cur info is not null;
%>		</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
	  <%
	  	if(vCourseInfo != null && vCourseInfo.size() > 0){
	  %>
      <td align="center">
	  <input type="submit" name="_" value="Print Result" onClick="printPg();" > <font size="2">Print this report show below as it is</font>  </td>
	  <%
	  	}
	  %>
      <td>&nbsp;</td>
    </tr>
	 <tr>
      <td height="25" colspan="4">&nbsp;</td>
    </tr>
  </table>	
  
 
<%
//for(iCtr=0;iCtr<vCurInfo.size();iCtr+=lineCtr){
	if(bolIsFirstPage == true && vSubBookInfo != null && vSubBookInfo.size() > 0){
		lineCtr = 4;
%> 
  
  <!-- PRINTING STARTS HERE -->
  
  	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="" id="">    
	<!-- HEADING -->  
	<%
		if(vCourseInfo != null && vCourseInfo.size() > 0)
			strTemp = (String)vCourseInfo.elementAt(1);
		else
			strTemp = "";
	%>
	<tr><td width="" align="center" colspan="6">&nbsp; <font color=""><strong><%=strTemp%></strong></font></td>
	</tr>  
	<%
		if(vCourseInfo != null && vCourseInfo.size() > 0)
			strTemp = "major in " + (String)vCourseInfo.elementAt(2);
		else
			strTemp = "";
			
		if(WI.fillTextValue("major_index").length() == 0 || WI.fillTextValue("major_index").compareTo("selany") == 0) 
			strTemp = "";		

	%>  
	<tr><td width="" align="center" colspan="6">&nbsp; <font color="" ><strong> <%=strTemp%></strong></font></td>
	</tr>		
	<tr><td width="" colspan="6">&nbsp;</td></tr>	
	<tr>
		<td width="57%" align="left" colspan="0">&nbsp;  <font size="2">Curriculum Year : <%=WI.fillTextValue("cy_from")%> - <%=WI.fillTextValue("cy_to")%></font></td>	
		
		<td width="43%" align="right" colspan="0">&nbsp; <font size="2"><font color="" >Date and Time Printed : <%=WI.getTodaysDateTime()%></font></font></td>			
	</tr>
	<!-- END OF HEADING -->
</table>

<%
for(iCtr=0;iCtr<vCurInfo.size();iCtr+=5){
		String strGetYear = (String)vCurInfo.elementAt(iCtr);
		String strGetSem  = (String)vCurInfo.elementAt(iCtr+1);
	
%>

<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable3">	
	<tr><td width="" colspan="6" align="center">&nbsp;</td></tr>
	<%if(prevYear != vCurInfo.elementAt(iCtr) || prevSem != vCurInfo.elementAt(iCtr+1)){%>	
		<tr><td width="" colspan="6" align="center"><%=strYearLevel[Integer.parseInt(strGetYear)]%><!--<%=strTempYear%>-->, <%=strSemester[Integer.parseInt(strGetSem)]%><!--<%=strTempSem%>--></td></tr>
	<%}%>
</table>	
<% lIndex = new Long((String)vCurInfo.elementAt(iCtr+2)); %>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="">
	<tr>
		<td width="10%">&nbsp;</td>		
	<td width="35%" align="left">&nbsp; <strong><font size="2"><%=(String)vCurInfo.elementAt(iCtr+3)%> - <%=(String)vCurInfo.elementAt(iCtr+4)%></font> </strong></td>
		<td width="20%">&nbsp; </td>	
		<td width="15%">&nbsp;</td>
		<td width="7%">&nbsp;</td>		
		<td width="8%">&nbsp;</td>				
	</tr>

	<tr>
		<td>
		</td>
		<td width="100%">		
			<table width="100%" border="1" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="">
				<tr>
					<!--COLUMN HEADING are generated from initialized String if there is a record-->
					<td width="35%" class="">&nbsp;<strong> <font size="2"><%=strTitle%></font></strong></td>
					<td width="20%">&nbsp;<strong> <font size="1"><%=strAuthor%></font></strong></td>	
					<td width="15%" align="center"><strong> <font size="1"><%=strYearPrinted%></font></strong></td>
					<td width="7%" align="center"> <strong><font size="1"><%=strQty%></font></strong></td>	
					<!-- END OF COLUMN HEADING -->	
				</tr>
			<%
				lineCtr += 1;				
				iIndexOf = vSubBookInfo.indexOf(lIndex);
				while(iIndexOf != -1){		
			%>	
				<tr>
					<td width="45%">&nbsp; <font size="2"><%=(String)vSubBookInfo.elementAt(iIndexOf+1)%></font></td>
					<td width="20%">&nbsp; <font size="2"><%=(String)vSubBookInfo.elementAt(iIndexOf+2)%></font></td>	
					<td width="10%" align="center"><font size="2"><%=(String)vSubBookInfo.elementAt(iIndexOf+3)%></font></td>
					<td width="7%" align="center"><font size="2"><%=(String)vSubBookInfo.elementAt(iIndexOf+4)%></font></td>	
				</tr>
				<%
					iIndexOf = vSubBookInfo.indexOf(lIndex, iIndexOf+1);
					lineCtr += 1;
					
					if(lineCtr>=40){	
							bolIsFirstPage=false;						
							lineCtr=0;
				%>
					<div style="page-break-before:always"></div>
				<%
						}//end of if(lineCtr>40)
					
				}//end of while(iIndexOf != -1)
				%>	
			</table> 	
		</td>
		<td>
		</td>
	</tr>
</table>
<%	
		lineCtr += 2;
		
		if(lineCtr>=40){	
				bolIsFirstPage=false;						
				lineCtr=0;
%>
				<div style="page-break-before:always"></div>
				
<%
			}//end of if(lineCtr>40)
		
		prevYear = (String)vCurInfo.elementAt(iCtr);
		prevSem  = (String)vCurInfo.elementAt(iCtr+1);	
	}//end of for(int iCtr=0;iCtr<=vCurInfo.size()-1;iCtr+=5)
	
}//end of if(bolIsFirstPage == true)

%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myTableAD3">
<tr><td>&nbsp;</td></tr>
<tr bgcolor="#A49A6A"><td height="25">&nbsp;</td></tr>
</table>
</form>
	
</body>
</html>
<%
dbOP.cleanUP();
%>
