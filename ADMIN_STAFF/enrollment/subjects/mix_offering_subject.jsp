<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/reportlink.css" rel="stylesheet" type="text/css">
</head>
<script src="../../../jscript/common.js"></script>
<script language="JavaScript">
function MixOffering(){
	document.form_.mix_offering.value = "1";
	document.form_.submit();
}
function ReloadPage() {
	document.form_.submit();
}

</script>


<style type="text/css">
#link {
	cursor:pointer;	
}
</style>


<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.ChangeStudentSched,java.util.Vector " buffer="16kb" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp = null;
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	
	if (strSchCode == null)
		strSchCode = "";	

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-MIX OFFERING","mix_offering_subject.jsp");
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
														"Enrollment","MIX OFFERING",request.getRemoteAddr(),
														"mix_offering_subject.jsp");
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
ChangeStudentSched chngStudSched       = new ChangeStudentSched();
enrollment.SubjectSection SS           = new enrollment.SubjectSection();
enrollment.ReportEnrollment reportEnrl = new enrollment.ReportEnrollment();
//enrollment.ReportEnrollment2 reportEnrl2 = new enrollment.ReportEnrollment2();

Vector vStudFr = null;
Vector vSecDetailFr = null;
Vector vCourseList = new Vector();
Vector vRetResult = null;

String strTemp2 = null;

String strSYFrom = WI.fillTextValue("sy_from");
String strSYTo = WI.fillTextValue("sy_to");
String strSemester = WI.fillTextValue("semester");


if(WI.fillTextValue("mix_offering").length() > 0){
		vRetResult = SS.operateOnMixSubject(dbOP, request, 1);
		if(vRetResult == null)
			strErrMsg = SS.getErrMsg();
}



if(WI.fillTextValue("sub_index_fr").length() > 0 && strSYTo.length() > 0) {
	vStudFr = chngStudSched.getSubjectSecList(dbOP, WI.fillTextValue("sub_index_fr"), strSYFrom,
                                 strSYTo, strSemester);
}
if(WI.fillTextValue("sub_sec_index_fr").length() > 0)
	vSecDetailFr = reportEnrl.getSubSecSchDetail(dbOP,WI.fillTextValue("sub_sec_index_fr"));	
	
if(WI.fillTextValue("sub_index_to").length() > 0){
		vCourseList = SS.operateOnMixSubject(dbOP, request, 5);
}


	
%>
<form name="form_" action="mix_offering_subject.jsp" method="post">
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" colspan="3" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF"><strong>:::: 
          MIX OFFERING SUBJECT ::::</strong></font></div></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td height="25" colspan="3"><font size="2" color="#FF0000"><strong><%=WI.getStrValue(strErrMsg)%></strong></font></td>
    </tr>
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td width="12%" height="25">School Year/Term</td>
      <td width="86%" height="25" colspan="2"> 
<%
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
	  readonly="yes"> &nbsp;&nbsp;&nbsp;&nbsp; <select name="semester" onChange="ReloadPage();">
          <option value="0">Summer</option>
          <%
strTemp = WI.fillTextValue("semester");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");
if(strTemp.compareTo("1") ==0){%>
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
        </select>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        <a href="javascript:ReloadPage();"><img src="../../../images/form_proceed.gif" border="0"></a></td>
    </tr>
  </table>
<%
if(WI.fillTextValue("sy_to").length() > 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr><td height="18" colspan="3"><hr size="1" color="#FFCC00"></td></tr>
	<tr>
		<td valign="top" width="50%">
			<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
				<tr> 				  
				  <td width="45%" height="25">Subject Code 
					<select name="sub_index_fr" onChange="ReloadPage();">
					<%
					strTemp = " from subject join e_sub_section on (e_sub_section.sub_index = subject.sub_index) "+
						" where e_sub_section.IS_DEL=0 and e_sub_section.is_valid = 1 "+
						" and e_sub_section.offering_sy_from = "+WI.fillTextValue("sy_from")+
						" and offering_sem = "+WI.fillTextValue("semester")+
						" order by sub_code asc";
					%>
					<option value="">Select a subject</option>
						<%=dbOP.loadComboDISTINCT("subject.sub_index","sub_code", strTemp,request.getParameter("sub_index_fr"), false)%>
					</select></td>
				</tr>
				
				<tr> 				  
				  <td height="25"><strong>
				  <%if(WI.fillTextValue("sub_index_fr").length() > 0){%>
				  <%=dbOP.mapOneToOther("subject","sub_index",WI.getStrValue(WI.fillTextValue("sub_index_fr"),"0"),"sub_name",null)%><%}%></strong></td>
				</tr>
				<tr> 				  
				  <td height="25">Section 
			<% 
			if(vStudFr != null && vStudFr.size() > 0){
			strTemp = WI.fillTextValue("sub_sec_index_fr");
			%>
					<select name="sub_sec_index_fr" onChange="ReloadPage();">
					<option value="">Select a Section</option>
			<%for(int i = 0 ; i < vStudFr.size(); i += 2){
			
				if (strSchCode.startsWith("CPU")) 
					strTemp2 = (String)vStudFr.elementAt(i);
				else
					strTemp2 = (String)vStudFr.elementAt(i + 1);
			
				if(strTemp.compareTo((String)vStudFr.elementAt(i)) == 0) {%>
				<option value="<%=(String)vStudFr.elementAt(i)%>" selected><%=strTemp2%></option>
				<%}else{%>
				<option value="<%=(String)vStudFr.elementAt(i)%>"><%=strTemp2%></option>
				<%}
			}%>
					</select>
			<%}%>		</td>
				</tr>
				
				
				<tr> 				 
				  <td height="25" valign="top">
			<%if(vSecDetailFr != null && vSecDetailFr.size() > 0){%>
			
			<table bgcolor="#000000">    
				<tr> 
				  <td bgcolor="#99CCFF"><div align="center"><font color="#000099" size="1"><strong>ROOM 
							#</strong></font></div></td>
				  <td bgcolor="#99CCFF"><div align="center"><font color="#000099" size="1"><strong>LOCATION</strong></font></div></td>
				  <td bgcolor="#99CCFF"><div align="center"><font color="#000099" size="1"><strong>SCHEDULE</strong></font></div></td>
				</tr>
				<%
				for(int i = 1; i<vSecDetailFr.size(); i+=3){%> 
				<tr bgcolor="#FFFFFF">
					<td align="center"><%=(String)vSecDetailFr.elementAt(i)%></td>
					<td align="center"><%=(String)vSecDetailFr.elementAt(i+1)%></td>
				 	<td align="center"><%=(String)vSecDetailFr.elementAt(i+2)%></td>
				</tr>  
				<%} //end of for loop.%> 
			 </table>
			 <%}//only if vSecDetailFr != null%>	 </td>
				</tr>
				
				
			</table>
		</td>
		
		
		
		
		
		
		<td valign="top">
			<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
				<tr>	
				  <td colspan="2" height="25">Subject Code 
					<select name="sub_index_to" onChange="ReloadPage();">
					<option value="">Select a subject</option>
			<%
			strTemp = WI.fillTextValue("sub_index_to");
			
			strErrMsg = " from subject join e_sub_section on (e_sub_section.sub_index = subject.sub_index) "+
					" where e_sub_section.IS_DEL=0 and e_sub_section.is_valid = 1 "+
					" and e_sub_section.offering_sy_from = "+WI.fillTextValue("sy_from")+
					" and offering_sem = "+WI.fillTextValue("semester")+" order by sub_code asc ";
				
			%>
			<%=dbOP.loadComboDISTINCT("subject.sub_index","sub_code", strErrMsg,strTemp, false)%>
					</select></td>
				</tr>
				
			<tr> 			  
			  <td height="25" colspan="2"><strong>
			  <%if(strTemp.length() > 0){%>
			  <%=dbOP.mapOneToOther("subject","sub_index",WI.getStrValue(strTemp,"0"),"sub_name",null)%><%}%></strong></td>
			</tr>		
				
				<%
				int iCount = 1;
				int j = 0;
				
				if(vCourseList != null && vCourseList.size() > 0){
					while(vCourseList.size() > 0){
				%>
				<tr> 
					<td width="50%">
						<%if(vCourseList.size() > 0){%>
						<input type="checkbox" name="course_<%=iCount++%>" value="<%=(String)vCourseList.remove(0)%>"><%=(String)vCourseList.remove(0)%>
						<%
						vCourseList.remove(0);
						}%>
					</td>
					<td>
						<%if(vCourseList.size() > 0){%>
						<input type="checkbox" name="course_<%=iCount++%>" value="<%=(String)vCourseList.remove(0)%>"><%=(String)vCourseList.remove(0)%>
						<%
						vCourseList.remove(0);
						}%>
					</td>
				</tr>
				<%}%>
				
				<input type="hidden" name="item_count" value="<%=iCount%>">
				
				<%}%>
			</table>
		</td>
	</tr>    
	
	<tr>
		<td>&nbsp;</td>
		<td align="center"><input type="button" value="MIX OFFERING" onClick="MixOffering();" name="cmdMixOffering" id="link"></td>
	</tr>
  </table>
<%}%>



<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
<tr><td height="25" colspan="2">&nbsp;</td></tr>
<tr bgcolor="#A49A6A"><td height="25" colspan="2">&nbsp;</td></tr>
</table>
  
  

  <input type="hidden" name="mix_offering">
  
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
