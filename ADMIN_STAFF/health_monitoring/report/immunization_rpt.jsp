<%@ page language="java" import="utility.*, health.HMReports ,java.util.Vector " %>
<%
String[] strColorScheme = CommonUtil.getColorScheme(8);
//strColorScheme is never null. it has value always.
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;

%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<script language="javascript"  src ="../../../jscript/common.js" ></script>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
</head>
<script language="JavaScript">
function ReloadPage()
{
	document.form_.print_page.value= "";
	document.form_.executeSearch.value = "1";
	document.form_.submit();
}
function StartSearch()
{
	document.form_.executeSearch.value = "1";
	document.form_.print_page.value= "";
	this.SubmitOnce('form_');
}

function PrintPg(){
	document.form_.print_page.value="1";
	this.SubmitOnce("form_");
}
</script>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	Vector vRetResult = null;
 
	String strInfoIndex = null;
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	int iSearchResult = 0;
	String[] astrSortByName = null;
	String[] astrSortByVal  = null;
	
	if(!bolIsSchool) {
		astrSortByName = new String[3];
		astrSortByName[0] = "Immunization Name"; astrSortByName[1]="ID Number"; astrSortByName[2]="FirstName";
		astrSortByVal  = new String[3];
		astrSortByVal[0] = "immun_name"; astrSortByVal[1]="id_number"; astrSortByVal[2]="fname";
	}
	else{
		astrSortByName = new String[5];
		astrSortByName[0] = "Immunization Name"; astrSortByName[1]="ID Number"; astrSortByName[2]="FirstName";astrSortByName[3]="College/Course";astrSortByName[4]="Department/Major";
		astrSortByVal  = new String[5];
		astrSortByVal[0] = "immun_name"; astrSortByVal[1]="id_number"; astrSortByVal[2]="fname";astrSortByVal[3]="coll_course";astrSortByVal[4]="dept_major";
	}
	
	if (WI.fillTextValue("print_page").length() > 0){ %>
		<jsp:forward page="./immunization_rpt_print.jsp"/>
	<% return;}

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Health Monitoring-Clinic Visit Log","immunization_rpt.jsp");
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
														"Health Monitoring","Clinic Visit Log",request.getRemoteAddr(),
														"immunization_rpt.jsp");
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
  String[] strConvertAlphabet = {"A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"};
	HMReports hmReports = new HMReports();
 	
	if (WI.fillTextValue("executeSearch").compareTo("1")==0){
	vRetResult = hmReports.viewImmunization(dbOP, request);
	if(vRetResult == null)
		strErrMsg = hmReports.getErrMsg();
	else
		iSearchResult = hmReports.getSearchCount();
 	if (strErrMsg == null)
		strErrMsg = hmReports.getErrMsg();
	}
%>
<body bgcolor="#8C9AAA" class="bgDynamic">
<form action="./immunization_rpt.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#697A8F"> 
      <td width="61%" height="28" align="center" class="footerDynamic"><font color="#FFFFFF" ><strong>:::: 
        <font size="2">IMMUNIZATION </font> - LISTINGS PAGE ::::</strong></font></td>
    </tr>
    <tr bgcolor="#697A8F"> 
      <td height="18" bgcolor="#FFFFFF"><%=WI.getStrValue(strErrMsg)%></td>
    </tr>
  </table>
  
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
<%if(bolIsSchool){%>
	<tr bgcolor="#697A8F">
      <td width="3%" height="33" bgcolor="#FFFFFF">&nbsp;</td>
      <td width="18%" bgcolor="#FFFFFF">Patient option </td>
      <td width="79%" bgcolor="#FFFFFF">
			<select name="user_type" onChange="ReloadPage();">
        <option value="">Show All</option>
        <% if(WI.fillTextValue("user_type").equals("0")){%>
        <option value="0" selected>Show only Employees</option>
        <%}else{%>
        <option value="0">Show only Employees</option>
        <%}%>
        <% if(WI.fillTextValue("user_type").equals("1")){%>
        <option value="1" selected>Show only students</option>
        <%}else{%>
        <option value="1">Show only students</option>
        <%}%>				
      </select></td>
    </tr>
		<%if(WI.fillTextValue("user_type").equals("1")){%>
    <tr bgcolor="#697A8F">
      <td height="25" bgcolor="#FFFFFF">&nbsp;</td>
      <td bgcolor="#FFFFFF">Year / Sem</td>
      <td bgcolor="#FFFFFF">
        <% strTemp = WI.fillTextValue("sy_from");
				if(strTemp.length() ==0)
					strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from"); %>
							<input name="sy_from" type="text" size="4" maxlength="4"  value="<%=strTemp%>" class="textbox"
					onFocus= "style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
					onKeyPress= " if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
					onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
			to
			<%  strTemp = WI.fillTextValue("sy_to");
				if(strTemp.length() ==0)
					strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to"); %>
			<input name="sy_to" type="text" size="4" maxlength="4" 
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
			</select>			</td>
    </tr>
<%}
}//show only if called from school.. 
else{%>
	<input type="hidden" name="user_type" value="0">
<%}%>
    <tr bgcolor="#697A8F">
      <td width="3%" height="25" bgcolor="#FFFFFF">&nbsp;</td>
      <td width="18%" bgcolor="#FFFFFF"><span class="thinborder">Immunization</span> name </td>
      <td width="79%" bgcolor="#FFFFFF"><strong>
        <%strTemp = WI.fillTextValue("vaccine");%>
        <select name="vaccine">
          <option value="">Select name of vaccine</option>
          <%=dbOP.loadCombo("IMMUN_NAME_INDEX","IMMUN_NAME"," FROM HM_PRELOAD_IMMUNIZATION", strTemp, false)%>
        </select>
      </strong>
<%
strTemp = WI.fillTextValue("show_complied");
if(strTemp.length() == 0) 
	strTemp = "0";
if(strTemp.equals("0"))
	strErrMsg =" checked";
else	
	strErrMsg = "";
%>	  
	  <input type="radio" name="show_complied" value="0" <%=strErrMsg%>> 
	  Show only not complied
      <%
if(strTemp.equals("1"))
	strErrMsg =" checked";
else	
	strErrMsg = "";
%>	  
	  <input type="radio" name="show_complied" value="1" <%=strErrMsg%>> 
	  Show only complied
      <%
if(strTemp.equals("2"))
	strErrMsg =" checked";
else	
	strErrMsg = "";
%>	  
	  <input type="radio" name="show_complied" value="2" <%=strErrMsg%>>Show all
	  
	  </td>
    </tr>
    
    <tr bgcolor="#697A8F">
      <td height="25" bgcolor="#FFFFFF">&nbsp;</td>
      <td colspan="2" bgcolor="#FFFFFF">Search   whose lastname starts 
        with
        <select name="lname_from" onChange="ReloadPage();">
          <%
	 strTemp = WI.fillTextValue("lname_from");
	 int j = 0; //displays from and to to avoid conflict -- check the page ;-)
	 for(int i=0; i<26; ++i){
	 if(strTemp.compareTo(strConvertAlphabet[i]) ==0){
	 j = i; %>
          <option selected><%=strConvertAlphabet[i]%></option>
          <%}else{%>
          <option><%=strConvertAlphabet[i]%></option>
          <%}
			}%>
        </select>
to
<select name="lname_to">
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
</select></td>
    </tr>
    <tr bgcolor="#697A8F">
      <td height="25" colspan="3" bgcolor="#FFFFFF"><hr size="1"></td>
    </tr>
    
    <tr bgcolor="#697A8F"> 
      <td height="25" bgcolor="#FFFFFF">&nbsp;</td>
      <td colspan="2" bgcolor="#FFFFFF">SORT BY</td>
    </tr>
    <tr bgcolor="#697A8F"> 
      <td height="25" bgcolor="#FFFFFF">&nbsp;</td>
      <td colspan="2" bgcolor="#FFFFFF"><select name="sort_by1">
			<option value="">N/A</option>
	          <%=hmReports.constructSortByDropList(WI.fillTextValue("sort_by1"),astrSortByName,astrSortByVal)%> 
			</select>&nbsp;&nbsp;
			<select name="sort_by1_con">
				<option value="asc">Ascending</option>
			<% if(WI.fillTextValue("sort_by1_con").compareTo("desc") ==0){%>
	          <option value="desc" selected>Descending</option>
			<%}else{%>
	          <option value="desc">Descending</option>
			<%}%>
			</select>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			<select name="sort_by2">
			<option value="">N/A</option>
	          <%=hmReports.constructSortByDropList(WI.fillTextValue("sort_by2"),astrSortByName,astrSortByVal)%> 
			</select>
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
      <td colspan="2" bgcolor="#FFFFFF"><a href="javascript:StartSearch();"><img src="../../../images/form_proceed.gif" border="0"></a></td>
    </tr>
  </table>
 <%if (vRetResult!=null && vRetResult.size()>0){%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr>
      <td align="right"><font size="2">Number of records per page :</font>
        <select name="num_rec_page">
          <% int iDefault = Integer.parseInt(WI.getStrValue(request.getParameter("num_rec_page"),"20"));
			for(int i =10; i <=45 ; i++) {
				if ( i == iDefault) {%>
          <option selected value="<%=i%>"><%=i%></option>
          <%}else{%>
          <option value="<%=i%>"><%=i%></option>
          <%}
			}%>
        </select>
        <a href="javascript:PrintPg()"> <img src="../../../images/print.gif" border="0"></a> <font size="1">click to print</font></td>
    </tr>
  </table>
  <table width="100%" border="0" bgcolor="#FFFFFF" class="thinborder" cellpadding="0" cellspacing="0">
    <tr bgcolor="#FFFF9F"> 
      <td height="25" colspan="5" align="center" class="thinborder"><strong><font size="2">IMMUNIZATION SEARCH RESULT </font></strong></td>
    </tr>
    <tr>
      <td height="25" colspan="2" class="thinborder"><font size="1">TOTAL :<strong>&nbsp;<%=iSearchResult%></strong></font></td> 
      <td colspan="3" class="thinborder">  <div align="right"><font size="1"> 
          <%
	  //if more than one page , constuct page count list here.  - 20 default display per page)
		int iPageCount = iSearchResult/hmReports.defSearchSize;
		if(iSearchResult % hmReports.defSearchSize > 0) ++iPageCount;
		if(iPageCount > 1)
		{%>
          Jump To page: 
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
          <%} else {%>
          &nbsp; 
          <%}%></font>
          </div></td>
    </tr>
    <tr style="font-weight:bold" align="center">
      <td width="10%" class="thinborder" style="font-size:9px;">Dosage Schedule </td> 
      <td width="11%" height="25" class="thinborder" style="font-size:9px;">ID #</td>
      <td width="36%" class="thinborder" style="font-size:9px;">Name</td>
      <td width="20%" class="thinborder" style="font-size:9px;"><%if(bolIsSchool){%>Unit/ Colleges<%}else{%>Division/Office<%}%></td>
      <td width="23%" class="thinborder" style="font-size:9px;">Immunization Name</td>
    </tr>
    <%for(int i =0; i<vRetResult.size(); i+=15){%>
    <tr>
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+14)%></td> 
      <td height="25" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+7)%></td>
      <td class="thinborder">&nbsp;<%=WI.formatName((String)vRetResult.elementAt(i+8), (String)vRetResult.elementAt(i+9), (String)vRetResult.elementAt(i+10),4)%></td>
      <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+12),WI.getStrValue((String)vRetResult.elementAt(i+13),"&nbsp;"))%></td>
      <td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+1),"&nbsp;")%></td>
    </tr>
    <%}%>
  </table>
<%}%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
     <tr>
      <td height="10" colspan="9">&nbsp;</td>
    </tr>
    <tr>
      <td height="25" colspan="9" bgcolor="#697A8F" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
  <input type="hidden" name="executeSearch" value="<%=WI.fillTextValue("executeSearch")%>">
	<input type="hidden" name="print_page">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
