<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
.courses {
height: 80px; width:auto; overflow: auto;
}
</style>
</head>
<script language="javascript" src="../../../jscript/td.js"></script>
<script language="javascript" src="../../../jscript/common.js"></script>
<script language="javascript">

function CancelOperation(){
	location="./grading_system_extn.jsp";
}

function PrepareToEdit(strInfoIndex, strCourseProgram){
	document.gsystem.searchGradingSystem.value = "1";
	document.gsystem.page_action.value = "";
	document.gsystem.info_index.value = strInfoIndex;
	document.gsystem.cc_index.value = strCourseProgram;
	document.gsystem.prepareToEdit.value = "1";
	document.gsystem.submit();
}

function PageAction(strAction,strInfoIndex){
	if(strAction == '0'){
		if(!confirm("Are you sure you want to delete this grading system info?"))
			return;
	}
	document.gsystem.searchGradingSystem.value = "1";
	document.gsystem.page_action.value = strAction;
	document.gsystem.info_index.value = strInfoIndex;
	if(strAction == '1') 
		document.gsystem.prepareToEdit.value='';
	if(strInfoIndex.length > 0)
		document.gsystem.info_index.value = strInfoIndex;
	document.gsystem.submit();
}

function ReloadPage(){
	document.gsystem.prepareToEdit.value = '';
	document.gsystem.page_action.value = '';
	document.gsystem.searchGradingSystem.value = '';
	document.gsystem.info_index.value = '';
	document.gsystem.submit();
}

function showGradingSystems(strProgIndex, strCourseIndex){
	document.gsystem.page_action.value = "";
	document.gsystem.searchGradingSystem.value = "1";
	document.gsystem.cc_index.value = strProgIndex;
	if(document.gsystem.course_index)
		document.gsystem.course_index.value = strCourseIndex;
	document.gsystem.submit();
}

</script>

<body bgcolor="#D2AE72">
<form name="gsystem" action="./grading_system_extn.jsp" method="post">
<%@ page language="java" import="utility.*,enrollment.GradeSystem,java.util.Vector " %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = "";
	String strTemp = null;
	
	//add security here.
		try
		{
			dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
									"Admin/staff-Registrar Management-GRADES-Grade System","grading_system_extn.jsp");
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
															"Registrar Management","GRADES",request.getRemoteAddr(),
															null);
	//if iAccessLevel == 0, i have to check if user is set for sub module.
	if(iAccessLevel == 0) {
		iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
										"Registrar Management","GRADES-Grading System",request.getRemoteAddr(),
										null);
	
	}
	
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

	GradeSystem GS = new GradeSystem();
	String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"),"");
	
	//check for add - edit or delete
	strTemp = WI.fillTextValue("page_action");
	if(strTemp.length() > 0){
		if(GS.operateOnGradeSystemExtn(dbOP, request, Integer.parseInt(strTemp)) == null)
			strErrMsg = GS.getErrMsg();
		else{
			if(strTemp.equals("0"))
				strErrMsg = "Grading system removed successfully.";
			if(strTemp.equals("1"))
				strErrMsg = "Grading system recorded successfully.";
			if(strTemp.equals("2"))
				strErrMsg = "Grading system edited successfully.";
				
			strPrepareToEdit = "";
		}
	}

	Vector vRetResult = new Vector();
	Vector vEditInfo = new Vector();
	Vector vGradingSystems = new Vector();
	int iSearchResult = 0;
	int i = 0;
	
	vGradingSystems = GS.viewGradingSystems(dbOP, request);
	
	if(WI.fillTextValue("searchGradingSystem").length() > 0){
		vRetResult = GS.operateOnGradeSystemExtn(dbOP, request,  4);
		if(vRetResult == null && strTemp.length() == 0)
			strErrMsg = GS.getErrMsg();
		else{
			if(strPrepareToEdit.length() > 0){
				vEditInfo = GS.operateOnGradeSystemExtn(dbOP, request, 3);
				if(vEditInfo == null)
					strErrMsg = GS.getErrMsg();
			}
		}
	}
%>

	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr bgcolor="#A49A6A"> 
			<td height="25" colspan="7"><div align="center">
				<font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif">
				<strong>:::: GRADING SYSTEM PAGE ::::</strong></font></div></td>
		</tr>
		<tr> 
			<td height="25">&nbsp;</td>
		    <td height="25" colspan="6"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
	    </tr>
		<tr> 
			<td height="25" width="3%">&nbsp;</td>
			<td height="25" colspan="2">Final point equivalent : 
			<%
				if(vEditInfo != null && vEditInfo.size() > 0)
					strTemp = (String)vEditInfo.elementAt(1);//school index.
				else
					strTemp = WI.getStrValue(WI.fillTextValue("final_pt"), "");
			%> 
				<input type="text" name="final_pt" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
					onBlur="AllowOnlyFloat('gsystem','final_pt');style.backgroundColor='white'" 
					onkeyup="AllowOnlyFloat('gsystem','final_pt')" size="4" maxlength="5" 
					value="<%=strTemp%>"/>			</td>
			<td height="25" width="9%">Status : &nbsp;&nbsp;&nbsp;</td>
	        <td width="38%">
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(8);//school index.
					else
						strTemp = WI.getStrValue(WI.fillTextValue("status"), "");
				%>
				<select name="status">
             		<%=dbOP.loadCombo("STATUS_INDEX","STATUS"," from GRADE_STATUS where IS_DEL=0",strTemp , false)%>
	            </select></td>
	  </tr>
	<tr> 
		<td height="26" valign="middle">&nbsp;</td>
		<td height="26" colspan="2"> Minimum percentage (%) required for the grade : 
		<%
			if(vEditInfo != null && vEditInfo.size() > 0)
				strTemp = (String)vEditInfo.elementAt(2);//school index.
			else
				strTemp = WI.getStrValue(WI.fillTextValue("min_ptg"),"");
		%>
			<input type="text" name="min_ptg" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
				onBlur="AllowOnlyFloat('gsystem','min_ptg');style.backgroundColor='white'" 
				onkeyup="AllowOnlyFloat('gsystem','min_ptg')" size="4" maxlength="5" 
				value="<%=strTemp%>"/>		</td>
	  <td height="26">Remarks :</td>
		<td height="26">
			<%
				if(vEditInfo != null && vEditInfo.size() > 0)
					strTemp = (String)vEditInfo.elementAt(9);//school index.
				else
					strTemp = WI.getStrValue(WI.fillTextValue("remark"), "");
			%>
			<select name="remark">
          		<%=dbOP.loadCombo("REMARK_INDEX","REMARK"," from REMARK_STATUS where IS_DEL=0",strTemp , false)%>
        	</select></td>
	</tr>
		<tr> 
			<td height="25" valign="middle">&nbsp;</td>
			<td height="25" colspan="2">Maximum percentage (%) required for the grade : 
			  <%
				if(vEditInfo != null && vEditInfo.size() > 0)
					strTemp = (String)vEditInfo.elementAt(3);//school index.
				else
					strTemp = WI.getStrValue(WI.fillTextValue("max_ptg"), "");
			%>
			  <input type="text" name="max_ptg" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
					onBlur="AllowOnlyFloat('gsystem','max_ptg');style.backgroundColor='white'" 
					onkeyup="AllowOnlyFloat('gsystem','max_ptg')" size="4" maxlength="5" 
					value="<%=strTemp%>"/>			</td>
		<td colspan="2" >
	<%if(iAccessLevel > 1){
			if(vEditInfo != null && vEditInfo.size() > 0){%>
				<a href="javascript:PageAction(2,'<%=(String)vEditInfo.elementAt(0)%>');">
					<img src="../../../images/edit.gif" border="0"></a>
			<%}else{%>
				<a href="javascript:PageAction(1,'');"><img src="../../../images/add.gif" border="0"></a>
			<%}%>	
			<a href="javascript:CancelOperation();"><img src="../../../images/cancel.gif" border="0"></a>
	<%}//if iAccessLevel > 1	%> </td>
		</tr>
		<tr>
			<td height="25" valign="middle">&nbsp;</td>
			<td colspan="2">Honor Point Equivalent : &nbsp;&nbsp;&nbsp;&nbsp;
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(4);//school index.
					else
						strTemp = WI.getStrValue(WI.fillTextValue("honor_pt"), "");
				%>
				<input type="text" name="honor_pt" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
					onBlur="AllowOnlyFloat('gsystem','honor_pt');style.backgroundColor='white'" 
					onkeyup="AllowOnlyFloat('gsystem','honor_pt')" size="4" maxlength="5" 
					value="<%=strTemp%>"/>			</td>
			<td colspan="2" rowspan="3" valign="top"><div class="courses">
				<%if(vGradingSystems != null && vGradingSystems.size() > 0){%>
				<table width="100%" cellpadding="0" cellspacing="0" border="0" class="thinborder">
					<tr>
						<td width="50%" height="18" bgcolor="#999999" style="font-weight:bold" class="thinborder">Program Name List with grading system already created </td>
					</tr>
					<%for(i=0;i<vGradingSystems.size();i+=4){%>
					<tr onClick="javascript:showGradingSystems('<%=(String)vGradingSystems.elementAt(i)%>','<%=WI.getStrValue((String)vGradingSystems.elementAt(i+2), "")%>')">
						<td class="thinborder" height="18"><%=(String)vGradingSystems.elementAt(i+1)%></td>
					</tr>
					<%}%>
				</table>
				<%}%></div>
			</td>
		</tr>
		<tr>
			<td height="25">&nbsp;</td>
		  	<td width="15%" valign="middle">Course Program : </td>
			<td width="35%">				
				<%
					if(vEditInfo != null && vEditInfo.size() > 0)
						strTemp = (String)vEditInfo.elementAt(7);//school index.
					else
						strTemp = WI.getStrValue(WI.fillTextValue("cc_index"), "");
				%>
			  	<select name="cc_index" onChange="ReloadPage();">
					<option value="">Select Program</option>
              		<%=dbOP.loadCombo("cc_index","cc_name"," from CCLASSIFICATION where IS_DEL=0 order by cc_name asc", strTemp, false)%>
       	  		</select></td>
		</tr>
		<tr>
			<td height="25" valign="middle">&nbsp;</td>
		  	<td><!--Course Code : --></td>
			<td>
				<%
					if(vEditInfo != null && vEditInfo.size() > 0){
						strTemp = (String)vEditInfo.elementAt(6);//school index.
					}
					else
						strTemp = WI.fillTextValue("course_index");
				%>
				<!--<select name="course_index" onChange="ReloadPage();">
          			<option value="">All Course</option>
          		<%
					if(WI.fillTextValue("cc_index").length()>0){%>
          				<%=dbOP.loadCombo("course_index","course_name"," from course_offered where IS_DEL=0 and is_valid=1 and cc_index="+
 						WI.fillTextValue("cc_index") +" order by course_name asc", strTemp, false)%>
          		<%}%>
        </select>-->			</td>
		</tr>
		<tr>
			<td height="25"></td>
			<td colspan="4" align="center"><font size="1">
				<a href="javascript:showGradingSystems('<%=WI.fillTextValue("cc_index")%>','<%=WI.fillTextValue("course_index")%>')">
					Reload
				</a></font>
			</td>
		</tr>
	</table>
	
<%if(vRetResult != null && vRetResult.size() > 0)//6 in one set ;-)
{%>
	<table width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr bgcolor="#B9B292">
			<td height="25" colspan="6"><div align="center"><strong>CURRENT GRADING SYSTEM</strong></div></td>
		</tr>
	</table>
	
	<table width="100%" border="1" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
		<tr> 
			<td width="5%"><div align="center"><font size="1"><strong>COUNT</strong></font></div></td>
			<td width="15%"><div align="center"><font size="1"><strong>FINAL POINT </strong></font></div></td>
			<td width="15%"><div align="center"><font size="1"><strong>MIN. %</strong></font></div></td>
			<td width="15%" align="center"><div align="center"><font size="1"><strong>MAX. % </strong></font></div></td>
			<td width="15%" align="center"><font size="1"><strong>HONOR POINT</strong></font></td>
			<td width="19%"><div align="center"><font size="1"><strong>REMARKS</strong></font></div></td>
			<td width="8%" align="center"><font size="1"><strong>EDIT</strong></font></td>
			<td width="8%" align="center"><font size="1"><strong>DELETE</strong></font></td>
		</tr>
	<%	
		int iCount = 1;
		for(i = 0 ; i< vRetResult.size(); i+=10, iCount++){%>
		<tr> 
			<td><div align="center"><%=iCount%></div></td>
			<td><div align="center"><%=(String)vRetResult.elementAt(i+1)%></div></td>
			<td><div align="center"><%=(String)vRetResult.elementAt(i+2)%></div></td>
			<td><div align="center"><%=(String)vRetResult.elementAt(i+3)%></div></td>
			<td><div align="center"><%=(String)vRetResult.elementAt(i+4)%></div></td>
			<td><div align="center"><%=(String)vRetResult.elementAt(i+5)%></div></td>
			<td align="center">
				<%if(iAccessLevel > 1){%> 
					<a href="javascript:PrepareToEdit('<%=(String)vRetResult.elementAt(i)%>','<%=(String)vRetResult.elementAt(i+7)%>');">
					<img src="../../../images/edit.gif" border="0"></a> 
				<%}else{%>
					Not authorized
				<%}%>			</td>
      		<td align="center">
				<%if(iAccessLevel ==2){%>
					<a href="javascript:PageAction(0, '<%=(String)vRetResult.elementAt(i)%>')">
					<img src="../../../images/delete.gif" border="0"></a> 
        		<%}else{%>
        			Not authorized
        		<%}%> </td>
    </tr>
    <%}//end of loop %>
	</table>
<%}//end of displaying %>

	<table width="100%"  cellpadding="0" cellspacing="0">
		<tr>
			<td bgcolor="#FFFFFF"><font color="#FFFFFF">&nbsp;</font></td>
		</tr>
		<tr>
			<td bgcolor="#FFFFFF"><font color="#FFFFFF">&nbsp;</font></td>
		</tr>
		<tr bgcolor="#A49A6A">
			<td>&nbsp;</td>
		</tr>
	</table>
	
	<input type="hidden" name="page_action" value="">
	<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
	<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
	<input type="hidden" name="searchGradingSystem">
</form>
</body>
</html>

<%
dbOP.cleanUP();
%>
