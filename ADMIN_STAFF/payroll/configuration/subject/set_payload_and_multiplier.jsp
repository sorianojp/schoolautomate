<%@ page language="java" import="utility.*,java.util.Vector, eDTR.ReportMultipleWH" %>
<%
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;
String[] strColorScheme = CommonUtil.getColorScheme(6);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Subject Type Implementation</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>
</head>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../../Ajax/ajax.js"></script>
<script language="JavaScript">
<!--
//all about ajax - to display student list with same name.
function AjaxMapName() {
		var strCompleteName = document.form_.emp_id.value;
		var objCOAInput = document.getElementById("coa_info");
		
		if(strCompleteName.length <=2) {
			objCOAInput.innerHTML = "";
			return ;
		}

		this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		var strURL = "../../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&is_faculty=1&name_format=4&complete_name="+
			escape(strCompleteName);

		this.processRequest(strURL);
}
-->
</script>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = "";
	String strTemp = null;

	//add security here. 
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("PAYROLL"),"0"));
	}
	
	if(iAccessLevel == -1)//for fatal error.
	{
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
		return;
	}

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-DTR-Subject Allowances","set_payload_and_multiplier.jsp");
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

//end of authenticaion code.
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if(strSchCode == null)
		strSchCode = "";

	Vector vRetResult = null;
	Vector vEditInfo = null;
	
	ReportMultipleWH rptMultiple = new ReportMultipleWH();
	
	String strPageAction = WI.fillTextValue("page_action");
	String strTemp2 = null;
	        // 0 - lecture
        // 1 - lab
        // 2 - rle
        // 3 - nstp
        // 4 - grad
	String[] astrSubType = {"", "Lec/lab","RLE","NSTP","Graduate"};
	
	if(strSchCode.startsWith("UC")) {
		astrSubType[1] = "-1";
		astrSubType[2] = "-1";
		astrSubType[3] = "-1";
	}

	String[] astrSortByName    = {"Subject Code","Subject Name","Subject Type"};
	String[] astrSortByVal     = {"sub_code","sub_name","fatima_subject_type"};

	boolean bolHasItems = false;
	int iCount = 1;
	int i = 0;
	int iSearchResult = 0;
	
	if (strPageAction.length() > 0){
		if (rptMultiple.operateOnFatimaSubjectTypes(dbOP,request,1) != null){
			strErrMsg = " Subject Type udpated successfully ";
		}else{
			strErrMsg = rptMultiple.getErrMsg();
		}
	}
	
	if(WI.fillTextValue("searchEmployee").length() > 0){
		
		vRetResult = rptMultiple.operateOnFatimaSubjectTypes(dbOP,request,4);
		
		if (vRetResult == null){
			strErrMsg = rptMultiple.getErrMsg();	
		}else{
			iSearchResult = rptMultiple.getSearchCount();
		}
	}	

%>

<body bgcolor="#D2AE72" class="bgDynamic">
<form action="./set_payload_and_multiplier.jsp" name="form_">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="5" align="center" class="footerDynamic"><font color="#FFFFFF" ><strong>:::: 
       PAYLOAD AND MULTIPLIER PER SUBJECT ::::</strong></font></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="23" colspan="3"><strong><%=WI.getStrValue(strErrMsg)%></strong></td>
    </tr>
    
    
    <% 
	String strCollegeIndex = null;
	strCollegeIndex = WI.fillTextValue("c_index");
	strCollegeIndex = WI.getStrValue(strCollegeIndex);
	%>
   
    <tr>
      <td height="25">&nbsp;</td>
      <td>Subject name  filter</td>
      <td><input type="text" name="name_filter" value="<%=WI.fillTextValue("name_filter")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="16">
      (enter part of the subject name)</td>
    </tr>
    <tr>
      <td width="3%" height="25">&nbsp;</td>
      <td width="20%">Subject Code  filter</td>
      <td width="77%"><input type="text" name="sub_filter" value="<%=WI.fillTextValue("sub_filter")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="16">
        (enter part of the subject code)</td>
    </tr>
    <tr>
      <td height="11" colspan="3">
        <input name="view_all" type="checkbox" value="checked" <%=WI.fillTextValue("view_all")%>> View ALL </td>
    </tr>
  </table>	
<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="10">&nbsp;</td>
      <td height="10">&nbsp;</td>
      <td height="10" colspan="2">
				<!--<input type="image" onClick="SearchEmployee()" src="../../../../images/form_proceed.gif"> -->
				<input type="button" name="proceed_btn" value=" Proceed " style="font-size:11px; height:26px;border: 1px solid #FF0000;" 
				onClick="SearchEmployee();">
        <font size="1">click to display employee list to print.</font></td>
    </tr>
  </table>	
  
 <% if (vRetResult != null) {%> 
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    
    <%if(WI.fillTextValue("view_all").length() == 0){
	int iPageCount = iSearchResult/rptMultiple.defSearchSize;		
	if(iSearchResult % rptMultiple.defSearchSize > 0) ++iPageCount;
	if(iPageCount > 1){%>
    <tr>
      <td><div align="right"><font size="2">Jump To page:
        <select name="jumpto" onChange="SearchEmployee();">
      <%
			strTemp = request.getParameter("jumpto");
			if(strTemp == null || strTemp.trim().length() ==0) strTemp = "0";

			for(i =1; i<= iPageCount; ++i )
			{
				if(i == Integer.parseInt(strTemp) ){%>
                  <option selected value="<%=i%>"><%=i%> of <%=iPageCount%></option>
                  <%}else{%>
                  <option value="<%=i%>"><%=i%> of <%=iPageCount%></option>
                  <%
					}
			}
			%>
          </select>
      </font></div></td>
    </tr>
    <%} // end if pages > 1
		}// end if not view all%>
  </table> 
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF">
	  <%
	  if((WI.fillTextValue("with_schedule")).equals("1"))
	    strTemp = "EMPLOYEES WITH ALLOWANCE";
	  else
	    strTemp = "EMPLOYEES WITHOUT ALLOWANCE";
	  %>	
    <tr> 
      <td height="25" colspan="5" align="center" bgcolor="#B9B292"><strong><%=strTemp%></strong></td>
    </tr>
    <tr> 
      <td width="5%" height="24" align="center" class="thinborderBOTTOMLEFTRIGHT">&nbsp;</td>
      <td width="26%" align="center" class="thinborderBOTTOMRIGHT"><strong>SUBJECT CODE </strong></td>
      <td align="center" class="thinborderBOTTOMRIGHT"><strong>SUBJECT NAME </strong></td>
      <td align="center" class="thinborderBOTTOMRIGHT"><strong>SUBJECT TYPE</strong></td>
      <%if(WI.fillTextValue("with_schedule").equals("1")){%>
			<%}%>			
			<%
				strTemp = "";
				if(WI.fillTextValue("selAllSave").length() > 0){
					strTemp = " checked";
				}else{
					strTemp = "";
				}
			%>
      <td align="center" class="thinborderBOTTOMRIGHT"><strong>SELECT ALL<br>
      </strong>          <input type="checkbox" name="selAllSave" value="0" onClick="checkAllSave();" <%=strTemp%>>      </td>
    </tr>
    
    <% String[] astrDeductAbsent={"../../../../images/x.gif","../../../../images/tick.gif"};
	for (i = 0; i< vRetResult.size() ; i+=15, iCount++) {%>
		<input type="hidden" name="sub_index_<%=iCount%>" value="<%=(String)vRetResult.elementAt(i)%>">
    <tr> 
      <td height="25" align="right" class="thinborderBOTTOMLEFTRIGHT"><%=iCount%>&nbsp;</td>
			<td class="thinborderBOTTOMRIGHT"><font size="1"><strong>&nbsp;<%=(String)vRetResult.elementAt(i+1)%></strong></font></td>
	
			<td width="52%" class="thinborderBOTTOMRIGHT">&nbsp;<%=(String)vRetResult.elementAt(i+2)%></td>
			<%
				strTemp = WI.getStrValue((String)vRetResult.elementAt(i+3));
				if(strTemp.equals("0"))
					strTemp = "1";
			%>
			<td width="17%" class="thinborderBOTTOMRIGHT">&nbsp;<%=astrSubType[Integer.parseInt(strTemp)]%></td>
			<td width="17%" align="center" class="thinborderBOTTOMRIGHT"><span class="thinborder">
        <input type="checkbox" name="save_<%=iCount%>" value="1" <%=strTemp%> tabindex="-1">
      </span></td>
    </tr>
    <%}// end for loop%>
		<input type="hidden" name="sub_count" value="<%=iCount%>">
  </table>
<table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF">		
    <tr> 
			<%
				strTemp = WI.fillTextValue("subject_type");
			%>
      <td height="18" colspan="2">New Subject Type : 
        <select name="subject_type">
			<%for(i = 1;i < astrSubType.length; i++){
				if(astrSubType[i].equals("-1"))
					continue;
					
					if(strTemp.equals(Integer.toString(i))){
				%>
					<option value="<%=i%>" selected><%=astrSubType[i]%></option>
				<%}else{%>
				<option value="<%=i%>"><%=astrSubType[i]%></option>
				<%}
				}%>
		</select></td>
    </tr>
    <tr> 
      <td height="35" colspan="2" align="center">  
        <% if (iAccessLevel > 1) {%>
				<!--
				<a href="javascript:AddRecord()"><img src="../../../../images/edit.gif" width="48" height="28"  border="0"></a>
				-->
				<input type="button" name="edit" value="  Edit  " style="font-size:11px; height:26px;border: 1px solid #FF0000;" onClick="javascript:AddRecord();">
				<font size="1">click to edit entries </font> 
				<input type="button" name="cancel" value=" Cancel " style="font-size:11px; height:26px;border: 1px solid #FF0000;" 
				onClick="javascript:CancelRecord();">				
				<font size="1">click to cancel entries</font> 
        <%} // end iAccessLevel > 1%>        </td>
    </tr>
    <tr> 
      <td width="5%" height="10">&nbsp;</td>
      <td width="95%" height="10" valign="bottom">&nbsp;</td>
    </tr>
  </table>	
<%}//end vRetResult != null%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25"  colspan="3">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25"  colspan="3" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
</form>
</body>
</html>
<%
	dbOP.cleanUP();
%>
