<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Print page</title>
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
    border-top: solid 2px #000000;
    border-right: solid 2px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;	
    }

    TD.thinborder {
    border-left: solid 2px #000000;
    border-bottom: solid 2px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }
    TD.thinborderBOTTOM {
    border-bottom: solid 2px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }

-->
</style>

</head>


<script language="JavaScript">
function submitForm() {
	document.form_.reloadPage.value='1';	
	document.all.processing.style.visibility = "visible";
	document.bgColor = "#FFFFFF";	
	document.forms[0].style.visibility = "hidden";
	document.forms[0].submit();
}

function PrintPg()
{
 	var vProceed = confirm("Please keep your printer ready and click <OK> to print.if you are not ready to print, please click cancel.");
	if(!vProceed)
		return;
	
	
	document.bgColor = "#FFFFFF";
	
	var obj = document.getElementById('myID1');
	obj.deleteRow(0);
	obj.deleteRow(0);	
		
	var obj1 = document.getElementById('myID2');
	obj1.deleteRow(0);
	obj1.deleteRow(0);	
		
	
	document.getElementById('myID3').deleteRow(0);	
	
	//alert("Click OK to print this page");
	window.print();//called to remove rows, make bg white and call print.	
}


</script>




<body>
<%@ page language="java" import="utility.*,java.util.Vector,java.text.*" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strTemp = null;	
	String strErrMsg = null;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-REPORT-enrollment summary","enrolment_summary.jsp");
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
														"Enrollment","REPORTS",request.getRemoteAddr(),
														"enrolment_summary.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";
String[] astrConvertSem = {"Summer", "First Semester", "Second Semester", "Third Semester"};
	
Vector vRetResult = new Vector();
String[] astrConvertToSem = {"Summer","1st Sem","2nd Sem","3rd Sem"};
if(WI.fillTextValue("reloadPage").length() > 0){

if(WI.fillTextValue("sy_from").length() > 0 && WI.fillTextValue("semester").length() > 0){
	strTemp = " select c_name, count(*) from stud_curriculum_hist  "+
		" join course_offered on (course_offered.course_index = stud_curriculum_hist.course_index) "+
		" join college on (college.c_index = course_offered.c_index) "+
		" where exists ( "+
		" 		select * from enrl_final_cur_list where "+ 
		" 		is_valid = 1 and is_temp_stud=0 and sy_from = stud_curriculum_hist.sy_from "+
		" 		and current_semester = stud_curriculum_hist.semester "+
		" 		and user_index = stud_curriculum_hist.user_index "+
		" ) "+
		" and stud_curriculum_hist.is_valid = 1 "+
		" and sy_from = "+WI.fillTextValue("sy_from")+" and semester = "+WI.fillTextValue("semester")+ 
		" group by c_name ";
	java.sql.ResultSet rs = dbOP.executeQuery(strTemp);
	while(rs.next()){
		vRetResult.addElement(rs.getString(1));
		vRetResult.addElement(rs.getString(2));
	}
	rs.close();
}
if(vRetResult.size() == 0)
	strErrMsg = "No result found.";
}
%>
<form action="./enrolment_summary_print_SWU.jsp" method="post" name="form_">
<%
if(strErrMsg != null){%>
<table width="100%">
	<tr>
		<td>
			<font size="3"> <strong><%=strErrMsg%></strong></font>
		</td>
	</tr>
</table>
<%
dbOP.cleanUP();
return;
}

%>


<table width="100%" border="0" cellpadding="0" cellspacing="0" id="myID1">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" colspan="4" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif">
	  <strong>:::: ENROLLMENT SUMMARY REPORT ::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">	
      <td height="25" colspan="4">&nbsp;&nbsp;&nbsp;&nbsp;<%=WI.getStrValue(strErrMsg)%></td>
    </tr>
  </table>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myID2">
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td width="16%" height="25">School year </td>
      <td width="44%" height="25"> <%
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
	  readonly="yes"> 
	  
	  &nbsp; &nbsp;<select name="semester">
          <option value="1">1st Sem</option>
          <%
strTemp =WI.fillTextValue("semester");
if(strTemp.length() ==0) strTemp = (String)request.getSession(false).getAttribute("cur_sem");
if(strTemp.compareTo("2") ==0){%>
          <option value="2" selected>2nd Sem</option>
          <%}else{%>
          <option value="2">2nd Sem</option>
          <%}if(strTemp.compareTo("3") ==0){%>
          <option value="3" selected>3rd Sem</option>
          <%}else{%>
          <option value="3">3rd Sem</option>
          <%}if(strTemp.compareTo("4") ==0){%>
          <option value="4" selected>4th Sem</option>
          <%}else{%>
          <option value="4">4th Sem</option>
          <%}if(strTemp.compareTo("0") ==0){%>
          <option value="0" selected>Summer</option>
          <%}else{%>
          <option value="0">Summer</option>
          <%}%>
      </select></td>
      <td width="38%">
	  <input type="button" name="Login" value="Generate Report" onClick="submitForm();">	  </td>
    </tr>
	
    <tr> 
      <td height="25" colspan="5">&nbsp;</td>
    </tr>
  </table>
<%if(vRetResult != null && vRetResult.size() > 0){%>
<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF" id="myID3">	
	<tr><td colspan="4" align="right"><a href="javascript:PrintPg();"><img src="../../../../../images/print.gif"  border="0"></a>
		<font size="1">Click to print report</font>
	</td></tr>
	<tr>
		<td width="14%" valign="top"> <img src="../../../../../images/logo/<%=strSchCode%>.gif" width="90" height="90" border="0"></td>
		<td width="86%" valign="top">
			<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
				<tr><td colspan="2"><strong><font size="+2"><%=SchoolInformation.getSchoolName(dbOP,true,false)%></font></strong></td></tr>
				<tr>
					<td height="20" width="54%" style="font-size:15px; font-weight:bold;">Electronic Data Processing</td>
					<%if(strSchCode.startsWith("SWU")){%>
					<td width="46%" rowspan="2" valign="top">		
						<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
							<tr><td width="18%"><i><font size="1">Phone: </font></i></td>
							<td width="82%"><i><font size="1">415-5555 loc. 134</font></i></td>
							</tr>
							<tr><td><i><font size="1">Website: </font></i></td><td><i><font size="1" color="#0000FF"><u>swu.edu.ph</u></font></i></td></tr>
							<tr><td><i><font size="1">E-mail: </font></i></td><td><i><font size="1">edp@swu.edu.ph</font></i></td></tr>
						</table>
					
					</td>
					<%}%>
				</tr>
				<%
				strTemp = WI.getStrValue(SchoolInformation.getAddressLine1(dbOP,false,false));
				strTemp += WI.getStrValue(SchoolInformation.getAddressLine2(dbOP,false,false), ", ","","");
				%>
				<tr><td height="20" style="font-size:12px;"><%=strTemp%></td></tr>				
			</table>
	  </td>
	</tr>	
	<tr><td></td><td><div  style="border-bottom:solid 2px #000000;"></div></td></tr>
	<tr><td colspan="2" align="center" valign="bottom" height="50">
		<font size="3"><strong>ENROLLMENT DATA</strong></font>
	</td></tr>
	<tr><td colspan="2" align="center" height="20"><strong>
		<%=astrConvertSem[Integer.parseInt(WI.getStrValue(WI.fillTextValue("semester"),"0"))]%> <%=WI.fillTextValue("sy_from")+"-"+WI.fillTextValue("sy_to")%></strong></td></tr>	
	<tr><td colspan="2" height="50">&nbsp;</td></tr>
</table>


<table width="80%" align="center" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF" class="thinborder">
	<tr>
		<td width="63%" height="30" align="center" class="thinborder"><strong><font size="2">DEPARTMENT</font></strong></td>
		<td width="37%" height="30" align="center" class="thinborder"><strong><font size="2">ENROLLMENT</font></strong></td>
	</tr>
	
	<%
	int iTotal = 0;
	for(int i = 0; i < vRetResult.size(); i+=2){
		iTotal += Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(i+1),"0"));
	%>
	<tr>
		<td class="thinborder" height="25"><i><%=vRetResult.elementAt(i)%></i></td>
		<td class="thinborder" align="right"><strong><%=NumberFormat.getIntegerInstance().format(Integer.parseInt((String)vRetResult.elementAt(i+1)))%></strong>&nbsp; </td>
	</tr>
	<%}%>
	<tr>
		<td align="center" class="thinborder" height="25"><strong><i>TOTAL</i></strong></td>
		<td align="right" class="thinborder"><strong><%=NumberFormat.getIntegerInstance().format(iTotal)%></strong>&nbsp; </td>
	</tr>
</table>

<table width="80%" align="center" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
	<tr><td colspan="3" height="20">&nbsp;</td></tr>
	<tr>
		<td width="30%" valign="middle"><div style="border-bottom:solid 3px #000000;"></div></td>
		<td height="20" bgcolor="#000000" align="center"><font color="#FFFFFF">Southwestern University</font></td>
		<td width="30%" valign="middle"><div style="border-bottom:solid 3px #000000;"></div></td>
	</tr>
</table>

<%}//only if vRetResult is not null


%>
<input type="hidden" name="reloadPage">
</form>


<!--- Processing Div --->

<div id="processing" style="position:absolute; top:100px; left:250px; width:400px; height:125px;  visibility:hidden">
<table cellpadding=0 cellspacing=0 border=0 Width=100% Height=100% align=Center>
      <tr>
            <td align="center" class="v10blancong">
			<p style="font-size:16px; font-weight:bold; font-family:Verdana, Arial, Helvetica, sans-serif"> Processing Request. Please wait ...... </p>
			
			<img src="../../../../../Ajax/ajax-loader_big_black.gif"></td>
      </tr>
</table>
</div>
</body>
</html>
<%
dbOP.cleanUP();
%>