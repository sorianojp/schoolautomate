<%@ page language="java" import="utility.*, health.Immunization,java.util.Vector " %>
<%
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;
String[] strColorScheme = CommonUtil.getColorScheme(8);
//strColorScheme is never null. it has value always.
%>
	<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
	<html>
	<head>
	<title>Untitled Document</title>
	<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
	<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
	<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
	</head>
	<script language="javascript"  src ="../../../jscript/common.js" ></script>
	<script language="JavaScript">
	<!--
	function ViewDetails(strInfoIndex)
	{
		var pgLoc = "./immunizations_detail.jsp?stud_id="+strInfoIndex;
		var win=window.open(pgLoc,"PrintWindow",'width=800,height=500,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
		win.focus();
	}
	function ReloadPage()
	{
		document.form_.print_page.value = "";
		this.SubmitOnce('form_');
	}
	function PrintPage(){
		document.form_.print_page.value = "1";
		this.SubmitOnce("form_");
	}
	-->
	</script>
	<%
	
		DBOperation dbOP = null;
		WebInterface WI = new WebInterface(request);
		Vector vRetResult = null;
		Vector vEditInfo = null;
		Vector vVaccines = null;
		int iMaxCount = 0;
	
		String strInfoIndex = null;
		String strPrepareToEdit = null;
		String strErrMsg = null;
		String strTemp = null;
		String strTemp2 = "";
	
	
		if(WI.fillTextValue("srch").length()>0)
			{
				strTemp = "College";
				strTemp2 = "COLLEGE.C_CODE";
			}
		else
			{
				strTemp = "Course";
				strTemp2 = "COURSE_OFFERED.COURSE_CODE";
			}
	if(!bolIsSchool) {
		strTemp = "";
		strTemp2 = "";
	}
	
	
		String[] astrSortByName    = {"ID number","Lastname","Firstname", strTemp };
		String[] astrSortByVal     = {"id_number","lname","fname", strTemp2};
		
		strPrepareToEdit = WI.getStrValue(request.getParameter("prepareToEdit"),"0");
		int iSearchResult = 0;
		
			if(WI.fillTextValue("print_page").compareTo("1") == 0) {%>
			<jsp:forward page="./print_immunizations.jsp" />
		<%	return;
		}
		
	
	
	
	//add security here.
		try
		{
			dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
									"Admin/staff-Health Monitoring-Immunizations","immunizations_listings.jsp");
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
															"Health Monitoring","Immunizations",request.getRemoteAddr(),
															"immunizations_listing.jsp.jsp");
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
	Immunization immune = new Immunization();
	vVaccines = immune.retrieveVaccines(dbOP);
	if(vVaccines != null && WI.fillTextValue("sy_from").length() > 0) {
		vRetResult = immune.viewListings(dbOP, request);
		if(vRetResult == null)
			strErrMsg = immune.getErrMsg();
		else		
			iSearchResult = immune.getSearchCount();
	}
	else
		strErrMsg = immune.getErrMsg();
	%>
	<body bgcolor="#8C9AAA" class="bgDynamic">
	<form action="./immunizations_listings.jsp" method="post" name="form_">
	  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr bgcolor="#697A8F"> 
		  <td width="61%" height="28" class="footerDynamic"><div align="center"><font color="#FFFFFF" ><strong>:::: 
			  IMMUNIZATIONS - LISTINGS PAGE ::::</strong></font></div></td>
		</tr>
		<tr bgcolor="#697A8F"> 
		  <td height="24" bgcolor="#FFFFFF">&nbsp;&nbsp;&nbsp;<strong><font size="3"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
		</tr>
	  </table>
	<%if (vVaccines != null && vVaccines.size()>0){%>
	  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	<tr>
	<%strTemp= WI.fillTextValue("srch");
	if (!strTemp.equals("1")){
	strTemp = "";
	strTemp2 = "checked";
	}
	else{
	strTemp = "checked";
	strTemp2 = "";
	}
	if(!bolIsSchool)
		strTemp = "checked";%>
	<td colspan="10">&nbsp;&nbsp;Search for:&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<input type="radio" name="srch" value="1" onClick="javascript:ReloadPage();" <%=strTemp%>>Employees 
	<%if(bolIsSchool){%>
	&nbsp;<input type="radio" name="srch" value="" onClick="javascript:ReloadPage();" <%=strTemp2%>>Students
	&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font size="1">If  students: </font>
	<% strTemp = WI.fillTextValue("sy_from");
	if(strTemp.length() ==0)
		strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from"); %> <input name="sy_from" type="text" size="4" maxlength="4"  value="<%=strTemp%>" class="textbox"
		onFocus= "style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
		onKeyPress= " if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
		onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
			to 
			<%  strTemp = WI.fillTextValue("sy_to");
	if(strTemp.length() ==0)
		strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to"); %> <input name="sy_to" type="text" size="4" maxlength="4" 
			  value="<%=strTemp%>" class="textbox"
		  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly="yes">
			/ 
			<select name="semester">
			  <%
	strTemp = WI.fillTextValue("semester");
	if(strTemp.length() ==0 )
		strTemp = (String)request.getSession(false).getAttribute("cur_sem");
	if(strTemp.compareTo("0") ==0){%>
			  <option value="0" selected>Summer</option>
			  <%}else{%>
			  <option value="0">Summer</option>
			  <%}if(strTemp.compareTo("1") ==0){%>
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
	<%}else{%>
	<input type="hidden" name="sy_from" value="0">
	<%}%>
			</td>
	</tr>
	<tr>
	<%strTemp= WI.fillTextValue("match");
	if (strTemp.compareTo("1")==0){
	strTemp = "checked";
	strTemp2 = "";
	}
	else{
	strTemp = "";
	strTemp2 = "checked";
	}%>
	<td colspan="10">&nbsp;&nbsp;Search options:<input type="radio" name="match" value="1" <%=strTemp%>>Match All &nbsp;&nbsp;&nbsp; <input type="radio" name="match" value="" <%=strTemp2%>>Match Any</td>
	</tr>
	<tr>
	<td colspan="10">&nbsp;</td>
	</tr>
	<tr>
	<td width="2%" >&nbsp;</td>
	<td width="22%" class="thinborderALL"><font size="1"><strong>VACCINE NAME</strong></font></td>
	<td width="8%" class="thinborderALL"><div align="center"><font size="1"><strong>NOT TAKEN</strong></font></div></td>
	<td width="9" class="thinborderALL"><div align="center"><font size="1"><strong>COMPLIED</strong></font></div></td>
	<td width="9" class="thinborderALL"><div align="center"><font size="1"><strong>NOT COMPLIED</strong></font></div></td>
	<td width="2%">&nbsp;</td>
	<td width="22%" class="thinborderALL"><font size="1"><strong>VACCINE NAME</strong></font></td>
	<td width="8%" class="thinborderALL"><div align="center"><font size="1"><strong>NOT TAKEN</strong></font></div></td>
	<td width="9%" class="thinborderALL"><div align="center"><font size="1"><strong>COMPLIED</strong></font></div></td>
	<td width="9" class="thinborderALL"><div align="center"><font size="1"><strong>NOT COMPLIED</strong></font></div></td>
	<td width="2%">&nbsp;</td>
	</tr>
	<%
	for (int i = 0;vVaccines != null && i<vVaccines.size(); i+=4){%>
	<tr>
	<td>&nbsp;</td>
	<td class="thinborderLEFT"><font size="1"><%=(String)vVaccines.elementAt(i+1)%></font></td>
	<td><div align="center">
		<%strTemp = WI.fillTextValue("chkNotTaken"+iMaxCount); 
		if (strTemp.length()>0)
		strTemp2 = "checked";
		else
		strTemp2 = "";%>
	<input name="chkNotTaken<%=iMaxCount%>" type="checkbox" value="<%=(String)vVaccines.elementAt(i)%>" <%=strTemp2%>></div></td>
	<td>
		<%strTemp = WI.fillTextValue("chkComplied"+iMaxCount); 
		if (strTemp.length()>0)
		strTemp2 = "checked";
		else
		strTemp2 = "";%>
	<div align="center"><input name="chkComplied<%=iMaxCount%>" type="checkbox" value="<%=(String)vVaccines.elementAt(i)%>" <%=strTemp2%>></div></td>
	<td class="thinborderRIGHT">
		<%strTemp = WI.fillTextValue("chkNotComplied"+iMaxCount); 
		if (strTemp.length()>0)
		strTemp2 = "checked";
		else
		strTemp2 = "";%>
	<div align="center"><input name="chkNotComplied<%=iMaxCount%>" type="checkbox" value="<%=(String)vVaccines.elementAt(i)%>" <%=strTemp2%>></div></td>
	<td>&nbsp;</td>
		<%
		++iMaxCount;
		if ((i+2)<vVaccines.size()){%>
	<td class="thinborderLEFT"><font size="1"><%=(String)vVaccines.elementAt(i+3)%></font></td>
	<td>
		<%strTemp = WI.fillTextValue("chkNotTaken"+iMaxCount); 
		if (strTemp.length()>0)
		strTemp2 = "checked";
		else
		strTemp2 = "";%>
	<div align="center"><input name="chkNotTaken<%=iMaxCount%>" type="checkbox" value="<%=(String)vVaccines.elementAt(i+2)%>" <%=strTemp2%>></div></td>
	<td>
		<%strTemp = WI.fillTextValue("chkComplied"+iMaxCount); 
		if (strTemp.length()>0)
		strTemp2 = "checked";
		else
		strTemp2 = "";%>
	<div align="center"><input name="chkComplied<%=iMaxCount%>" type="checkbox" value="<%=(String)vVaccines.elementAt(i+2)%>" <%=strTemp2%>></div></td>
	<td class="thinborderRIGHT">
		<%strTemp = WI.fillTextValue("chkNotComplied"+iMaxCount); 
		if (strTemp.length()>0)
		strTemp2 = "checked";
		else
		strTemp2 = "";%>
	<div align="center"><input name="chkNotComplied<%=iMaxCount%>" type="checkbox" value="<%=(String)vVaccines.elementAt(i+2)%>" <%=strTemp2%>></div></td>
	<%
	++iMaxCount;
	} else {%>
	<td class="thinborderLEFT">&nbsp;</td>
	<td>&nbsp;</td>
	<td>&nbsp;</td>
	<td class="thinborderRIGHT">&nbsp;</td>
	<%}%>
	<td>&nbsp;</td>
	</tr>
<%}//for loop%>
	<tr>
	<td>&nbsp;</td>
	<td class="thinborderBOTTOMLEFT">&nbsp;</td>
	<td class="thinborderBOTTOM">&nbsp;</td>
	<td class="thinborderBOTTOM">&nbsp;</td>
	<td class="thinborderBOTTOMRIGHT">&nbsp;</td>
	<td>&nbsp;</td>
	<td class="thinborderBOTTOMLEFT">&nbsp;</td>
	<td class="thinborderBOTTOM">&nbsp;</td>
	<td class="thinborderBOTTOM">&nbsp;</td>
	<td class="thinborderBOTTOMRIGHT">&nbsp;</td>
	</tr>
	<tr>
	<td colspan="10">&nbsp;</td>
	</tr>
	</table>

	  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr bgcolor="#697A8F"> 
		  <td height="25" bgcolor="#FFFFFF">&nbsp;</td>
		  <td colspan="2" bgcolor="#FFFFFF"><strong>Sort Result </strong></td>
		</tr>
		<tr bgcolor="#697A8F"> 
		  <td height="25" bgcolor="#FFFFFF">&nbsp;</td>
		  <td colspan="2" bgcolor="#FFFFFF"><select name="sort_by1">
				<option value="">N/A</option>
				  <%=immune.constructSortByDropList(WI.fillTextValue("sort_by1"),astrSortByName,astrSortByVal)%> 
				</select>
				&nbsp;
				<select name="sort_by1_con">
					<option value="asc">Ascending</option>
				<% if(WI.fillTextValue("sort_by1_con").compareTo("desc") ==0){%>
				  <option value="desc" selected>Descending</option>
				<%}else{%>
				  <option value="desc">Descending</option>
				<%}%>
				</select>
				&nbsp;&nbsp;&nbsp;&nbsp;
				<select name="sort_by2">
				<option value="">N/A</option>
				  <%=immune.constructSortByDropList(WI.fillTextValue("sort_by2"),astrSortByName,astrSortByVal)%> 
				</select>
				&nbsp;
				<select name="sort_by2_con">
						<option value="asc">Ascending</option>
				<% if(WI.fillTextValue("sort_by2_con").compareTo("desc") ==0){%>
				  <option value="desc" selected>Descending</option>
				<%}else{%>
				  <option value="desc">Descending</option>
				<%}%>
				</select></td>
		</tr>
		<tr bgcolor="#697A8F"> 
		  <td height="43" bgcolor="#FFFFFF">&nbsp;</td>
		  <td bgcolor="#FFFFFF"><a href="javascript:ReloadPage();">
		  <img src="../../../images/form_proceed.gif" border="0"></a></td>
		  <td bgcolor="#FFFFFF"></td>
		</tr>
	   </table>
	   <%}//no vaccines
		if (vRetResult != null && vRetResult.size()>0){%>
	  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr> 
		  <td height="25" colspan="4" class="thinborder"><div align="right"><a href="javascript:PrintPage()"><img src="../../../images/print.gif" width="58" height="26" border="0"></a><font size="1">click
			  to print list</font></div></td>
		</tr>
		<tr > 
		  <td height="25" colspan="4" bgcolor="#FFFF9F" class="thinborderALL"><div align="center"><strong>IMMMUNIZATION LISTING</strong></div></td>
		</tr>
		 <tr>
			<td width="19%" height="25" colspan="4" class="thinborder"><div align="right">
			<%
		  //if more than one page , constuct page count list here.  - 20 default display per page)
			int iPageCount = iSearchResult/immune.defSearchSize;
			if(iSearchResult % immune.defSearchSize > 0) ++iPageCount;
			if(iPageCount > 1)
			{%>Jump To page: 
			  <select name="jumpto" onChange="ReloadPage();">
				<%
				strTemp = request.getParameter("jumpto");
				if(strTemp == null || strTemp.trim().length() ==0) strTemp = "0";
	
				for( int i =1; i<= iPageCount; ++i )
				{
					if(i == Integer.parseInt(strTemp) ){%>
				<option selected value="<%=i%>"><%=i%> of <%=iPageCount%></option>
				<%}else{%>
				<option value="<%=i%>"><%=i%> of <%=iPageCount%></option>
				<%}}%>
			  </select>
			  <%} else {%>&nbsp;<%}%>
			</div></td>
	</tr>
		<tr> 
		  <td width="18%" height="25" class="thinborder"><div align="center" ><font size="1"><strong>ID NO.</strong></font></div></td>
		  <td width="33%" class="thinborder"><div align="center"><font size="1"><strong>NAME</strong></font></div></td>
		  <td width="39%" class="thinborder"><div align="center"><font size="1"><strong><%strTemp = WI.fillTextValue("srch");
		  if (strTemp.length()>0){%>COLLEGE/DEPARTMENT/OFFICE<%}else{%>COURSE/MAJOR<%}%></strong></font></div></td>
		  <td width="10%" class="thinborder">&nbsp;</td>
		</tr>
	   <%for (int i = 0; i < vRetResult.size(); i+=7){%>
		<tr> 
		  <td height="25" class="thinborder"><font size="1"><%=(String)vRetResult.elementAt(i+1)%></font></td>
		  <td class="thinborder"><font size="1"><%=WI.formatName((String)vRetResult.elementAt(i+2),(String)vRetResult.elementAt(i+3),(String)vRetResult.elementAt(i+4),7)%></font></td>
		  <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+5),"&nbsp;")%><%=WI.getStrValue((String)vRetResult.elementAt(i+6),"&nbsp;")%></td>
		  <td class="thinborder"><div align="center"><a href='javascript:ViewDetails("<%=((String)vRetResult.elementAt(i+1))%>")'>
		  <img src="../../../images/view.gif" width="40" height="31" border="0"></a></div></td>
		</tr>
		<%}%>
	  </table>
	<%}%>
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr> 
		  <td height="10">&nbsp;</td>
		</tr>
	  </table>
	
	  <table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
		<tr >
		  <td height="25" colspan="9" bgcolor="#697A8F" class="footerDynamic">&nbsp;</td>
		</tr>
	  </table>
		<input type="hidden" name="cFields" value ="<%=iMaxCount%>">
		<input type="hidden" name="print_page">
	</form>
	</body>
	</html>
<%
dbOP.cleanUP();
%>