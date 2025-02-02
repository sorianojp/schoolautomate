<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function ReloadPage()
{
	if(document.form_.sy_to.value.length < 4 || document.form_.sy_from.value.length < 4) {
		alert("Please enter School Year information.");
		return;
	}
	document.form_.print_all.value ="";
	document.form_.print_pg.value = "";

	document.form_.submit();
}
function CallPrint()
{
	document.form_.print_all.value ="";
	document.form_.print_pg.value = "1";
}
function PrintALL() {
	document.form_.print_all.value ="1";
	document.form_.print_pg.value = "1";
	document.form_.submit();
}
function PrintPg(id_number)
{

	var loadPg = "./enrollment_receipt_print_uc_batch.jsp?stud_id="+
		id_number+"&sy_from="+document.form_.sy_from.value+
		"&sy_to="+document.form_.sy_to.value+"&semester="+
		document.form_.semester[document.form_.semester.selectedIndex].value;

	var win=window.open(loadPg,"myfile",'dependent=no,width=800,height=450,top=20,left=20,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,java.util.Vector" %>
<%
 
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;

	WebInterface WI = new WebInterface(request);

	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if (strSchCode == null)
		strSchCode = "";
//add security here.
	try
	{
		dbOP = new DBOperation();
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
														"Fee Assessment & Payments","REPORTS",request.getRemoteAddr(), null);	
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
}

//end of authenticaion code.
	
if(strErrMsg == null) strErrMsg = "";
String[] strConvertAlphabet = {"A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"};
String[] astrConvertTerm = {"Summer","1st Sem","2nd Sem","3rd Sem","4th Sem"};

boolean bolIsBasic = WI.fillTextValue("is_basic").equals("1");
//if() 
//	bolIsBasic = true;



//get here the list of student to be printed if the print by course is selected.
Vector vRetResult = new Vector();
EnrlReport.StatementOfAccount SOA = new EnrlReport.StatementOfAccount();
if(WI.fillTextValue("sy_from").length() > 0 && WI.fillTextValue("semester").length() > 0) {
	String strSQLQuery = "select distinct user_table.id_number,fname,mname,lname  from stud_curriculum_hist "+
		"join user_table on (stud_curriculum_hist.user_index = user_table.user_index) "+
		"join course_offered on (course_offered.course_index = stud_curriculum_hist.course_index) "+
		"join college on (college.c_index = course_offered.c_index) "+
		" where stud_curriculum_hist.is_valid = 1 and  stud_curriculum_hist.sy_from="+WI.fillTextValue("sy_from")+
		" and stud_curriculum_hist.semester = "+WI.fillTextValue("semester")+
		" and exists (select enroll_index from enrl_final_cur_list where is_valid = 1 and is_temp_stud = 0 and user_index = stud_curriculum_hist.user_index and "+
		" sy_from = stud_curriculum_hist.sy_from and current_semester = semester) "+
		" and college.c_index = "+WI.fillTextValue("college_index")+" order by lname,fname ";
	java.sql.ResultSet rs = dbOP.executeQuery(strSQLQuery);
	//System.out.println(strSQLQuery);
	while(rs.next()) {
		vRetResult.addElement(rs.getString(1));
		vRetResult.addElement(WebInterface.formatName(rs.getString(2),rs.getString(3),rs.getString(4),4));
	}	
	rs.close();
	if(vRetResult.size() == 0) 
		strErrMsg = "No Result found.";
	
}

String strStudCSVToPrint = null;
//if print all - i have to print all one by one..
if(WI.fillTextValue("print_all").compareTo("1") == 0 && WI.fillTextValue("show_all_in1page").length() > 0) {
	int iMaxPage = vRetResult.size()/2;
	if(WI.fillTextValue("print_option2").length() > 0) {
		//I have to now check if format entered is correct.
		int[] aiPrintPg = SOA.getPrintPage(WI.fillTextValue("print_option2"),iMaxPage);
		if(aiPrintPg == null) 
			strErrMsg = SOA.getErrMsg();
		else {//print here.
			for(int i = 0; i < aiPrintPg.length; ++i) {
				if(strStudCSVToPrint == null)
					strStudCSVToPrint = (String)vRetResult.elementAt(aiPrintPg[i] * 2 - 2);
				else
					strStudCSVToPrint = strStudCSVToPrint+","+(String)vRetResult.elementAt(aiPrintPg[i] * 2 - 2);
			}
		}//end if there is no err Msg.
	}
	else {
		//enter this only if page number is selected. -- but call the above only if page range in enter in the input box.
		int iPrintRangeTo = Integer.parseInt(WI.getStrValue(WI.fillTextValue("print_page_range"),"0"));
		int iPrintRangeFr = iPrintRangeTo - 25; 
		if(iPrintRangeFr < 1) 
			iPrintRangeFr = 0;
		if(iPrintRangeTo == iMaxPage && iMaxPage %25 > 0) {
			//i can't subtract just like that.. i have to find the last page count.
			iPrintRangeFr = iMaxPage - iMaxPage%25;
		}
		for(int i = 0,iCount = 0; i < vRetResult.size(); i += 2, ++iCount) {
			if(iPrintRangeTo > 0) {
				if( (iCount + 1) < iPrintRangeFr || (iCount + 1) > iPrintRangeTo)
					continue;
			}

			if(strStudCSVToPrint == null)
				strStudCSVToPrint = (String)vRetResult.elementAt(i);
			else
				strStudCSVToPrint = strStudCSVToPrint+","+(String)vRetResult.elementAt(i);
		}
	}//end of else.. 
	
}//end of printing.. 
if(strStudCSVToPrint != null) {
	dbOP.cleanUP();

	strTemp = "./enrollment_receipt_print_uc_batch_main_print.jsp";
	request.getSession(false).setAttribute("stud_list",strStudCSVToPrint);
		
	strTemp += "?sy_from="+WI.fillTextValue("sy_from")+"&sy_to="+WI.fillTextValue("sy_to")+"&semester="+WI.fillTextValue("semester");
			
		response.sendRedirect(response.encodeRedirectURL(strTemp));

	return;
}
%>

<form name="form_" action="./enrollment_receipt_print_uc_batch_main.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A"> 
      <td height="25" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          PRINT FINAL CLASS SCHEDULE ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF"> 
      <td height="25" >&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font size="3"><b><%=WI.getStrValue(strErrMsg)%></b></font></td>
    </tr>
  </table>
	
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="4%" height="25">&nbsp; </td>
      <td width="17%" height="25">SY/TERM</td>
      <td width="79%" height="25" colspan="2"> <%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%> <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
        to 
        <%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%> <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  readonly="yes"> <select name="semester">
<% 
strTemp = WI.fillTextValue("semester");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");
%>
          <option value="0">Summer</option>
<%if(strTemp.compareTo("1") ==0){%>
          <option value="1" selected>1st Sem</option>
          <%}else{%>
          <option value="1">1st Sem</option>
          <%}if(strTemp.compareTo("2") == 0){%>
          <option value="2" selected>2nd Sem</option>
          <%}else{%>
          <option value="2">2nd Sem</option>
          <%}if(strTemp.compareTo("3") == 0){%>
          <option value="3" selected>3rd Sem</option>
          <%}else{%>
          <option value="3">3rd Sem</option>
<%}%>
        </select> 
        &nbsp;&nbsp;&nbsp; <a href="javascript:ReloadPage();"><img src="../../../images/form_proceed.gif" border="0"></a>
		<input type="hidden" name="show_all_in1page" value="checked">		</td>
    </tr>
		<tr> 
		  <td height="25">&nbsp;</td>
		  <td height="25"> College </td>
		  <td height="25" colspan="2">
		  <select name="college_index">
			  <%=dbOP.loadCombo("c_index","c_name"," from college where is_del = 0 order by c_name", WI.fillTextValue("college_index"), false)%> 
		  </select></td>
		</tr>
<!--		
		<tr> 
		  <td height="25">&nbsp;</td>
		  <td height="25"> Course </td>
		  <td height="25" colspan="2"><select name="course_index" onChange="ReloadPage();" style="width:500px">
			  <option value="0">Select Any</option>
			  <%
	//for all course listing strTemp = " from course_offered where IS_DEL=0 AND IS_VALID=1 order by course_name asc"
	strTemp = " from course_offered where IS_DEL=0 AND IS_VALID=1 order by course_name asc";
	%>
			  <%=dbOP.loadCombo("course_index","course_name",strTemp, request.getParameter("course_index"), false)%> 
			</select></td>
		</tr>
		<tr> 
		  <td height="25">&nbsp;</td>
		  <td height="25">Major</td>
		  <td height="25" colspan="2"> <select name="major_index">
			  <option value="">ALL</option>
			  <%
	strTemp = request.getParameter("course_index");
	if(strTemp != null && strTemp.compareTo("0") != 0)
	{
	strTemp = " from major where is_del=0 and course_index="+strTemp ; 
	%>
			  <%=dbOP.loadCombo("major_index","major_name",strTemp, request.getParameter("major_index"), false)%> 
			  <%}%>
			</select></td>
		</tr>
 -->
    <tr> 
      <td height="25">&nbsp;</td>
      <td colspan="3" height="25">Print students whose lastname starts with 
        <select name="lname_from" onChange="ReloadPage()">
          <%
 strTemp = WI.fillTextValue("lname_from");
 int j = 0; //displays from and to to avoid conflict -- check the page ;-)
 for(int i=0; i<26; ++i){
 if(strTemp.compareTo(strConvertAlphabet[i]) ==0){
 j = i;%>
          <option selected><%=strConvertAlphabet[i]%></option>
          <%}else{%>
          <option><%=strConvertAlphabet[i]%></option>
          <%}
}%>
        </select>
        to 
        <select name="lname_to" onChange="ReloadPage()">
          <option value="0"></option>
          <%
 strTemp = WI.fillTextValue("lname_to");
 
 for(int i=++j; i<26; ++i){
 if(strTemp.compareTo(strConvertAlphabet[i]) ==0){%>
          <option selected><%=strConvertAlphabet[i]%></option>
          <%}else{%>
          <option><%=strConvertAlphabet[i]%></option>
          <%}
}%>
        </select> </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2">&nbsp; </td>
    </tr>
    <%
if(vRetResult != null && vRetResult.size() > 0){%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="3"><font size="3">TOTAL STUDENTS TO BE PRINTED 
        : <strong><%=vRetResult.size()/2%></strong></font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">PRINT OPTION 1</td>
      <td height="25" colspan="2"> <select name="print_page_range">
          <option value="">ALL</option>
          <%
	  strTemp = WI.fillTextValue("print_page_range");
	  int iTemp = vRetResult.size()/2;
	  int iLastCount = 0;
	  for(int i = 1; i <= iTemp;){
	  	i += 25; //in batch of 25
		if(i > iTemp)
			iLastCount = iTemp;
		else	
			iLastCount += 25;
		 if(strTemp.compareTo(Integer.toString(iLastCount)) == 0){%>
          <option value="<%=iLastCount%>" selected><%=i - 25%> to <%=iLastCount%></option>
          <%}else{%>
          <option value="<%=iLastCount%>"><%=i - 25%> to <%=iLastCount%></option>
          <%}
	  }%>
        </select></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td valign="top">PRINT OPTION 2</td>
      <td height="25" colspan="2" valign="top"><input name="print_option2" type="text" size="16" maxlength="32" 
	  value="<%=WI.fillTextValue("print_option2")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
        <br> <font color="#0099FF"> <strong>(Enter page numbers and/or page ranges 
        separated by commas. For ex: 1,3,5-12)</strong></font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2"> <input type="image" src="../../../images/form_proceed.gif" onClick="CallPrint()"> 
        <font size="1">click to display student list to print.</font></td>
    </tr>
<%}//only if vRetResult is not null;%>
  </table>
<%
if(vRetResult != null && vRetResult.size() > 0 && WI.fillTextValue("print_pg").compareTo("1") == 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="1" bgcolor="#000000">
    <tr bgcolor="#FFFFFF"> 
      <td height="25" colspan="4" align="right"><a href="javascript:PrintALL();"> 
        <img src="../../../images/print.gif" border="0"></a> <font size="1">Click 
        to print</font>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</td>
    </tr>
    <tr bgcolor="#999999"> 
      <td height="25" colspan="4" align="center"><B>LIST OF STUDENT FOR PRINTING.</B></td>
    </tr>
    <tr bgcolor="#ffff99"> 
      <td height="25" colspan="2" align="center"><strong>STUDENT ID</strong></td>
      <td width="40%" align="center"><strong>STUDENT NAME</strong></td>
      <td width="18%" align="center"><strong>PRINT</strong></td>
    </tr>
    <%
 for(int i = 0,iCount=1; i < vRetResult.size(); i += 2,++iCount){%>
    <tr bgcolor="#FFFFFF"> 
      <td width="6%"><%=iCount%>.</td>
      <td width="36%" height="25">&nbsp;&nbsp;<%=(String)vRetResult.elementAt(i)%></td>
      <td>&nbsp;&nbsp;<%=(String)vRetResult.elementAt(i + 1)%></td>
      <td align="center"><a href='javascript:PrintPg("<%=(String)vRetResult.elementAt(i)%>");'><img src="../../../images/print.gif" border="0"></a></td>
    </tr>
    <%}%>
  </table>
<%}//end of vRetResult display.
%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A"> 
      <td height="25">&nbsp;</td>
    </tr>
  </table>
  <input type="hidden" name="print_pg" value="">  
  <input type="hidden" name="print_all" value="">
</form>

</body>
</html>
<%
dbOP.cleanUP();
%>