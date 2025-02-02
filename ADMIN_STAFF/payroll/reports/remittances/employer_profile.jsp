<%@ page language="java" import="utility.*,java.util.Vector,payroll.PRRemittance"%>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
String[] strColorScheme = CommonUtil.getColorScheme(6);
//strColorScheme is never null. it has value always.
 %>
 <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Employer Profile</title>
<meta http-equiv="Content-Type" content=asd"text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}

	TD.thinborder {
	border-bottom: solid 1px #000000;
	border-left: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
	}
	TABLE.thinborder {
	border-top: solid 1px #000000;
	border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 10px;
	}

</style>
</head>
<script language="JavaScript" src="../../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript">

function CancelRecord(){
	location = "./employer_profile.jsp";
}

function PageAction(strAction,strIndex,strEmployer){
	if(strAction == 0){
		var vProceed = confirm('Delete '+strEmployer+' ?');
		if(!vProceed)
			return;
	}
	
	if(strAction == 1){
		document.form_.save.disabled = true;
	}	
	if(strAction == 3){
		document.form_.prepareToEdit.value = "1";
		
	}
	if(strAction == 3 || strAction == 0)
		document.form_.employer_index.value = strIndex;
	
	document.form_.page_action.value = strAction;	
	this.SubmitOnce('form_');
}

</script>

<%
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	String strTemp3 = null;
	String strImgFileExt = null;

//add security hehol.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Payroll-Reports-Remittances-Employer Profile","employer_profile.jsp");

		ReadPropertyFile readPropFile = new ReadPropertyFile();
		strImgFileExt = readPropFile.getImageFileExtn("imgFileUploadExt");

		if(strImgFileExt == null || strImgFileExt.trim().length() ==0)
		{
			strErrMsg = "Image file extension is missing. Please contact school admin.";
			dbOP.cleanUP();
			throw new Exception();
		}
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		if(strErrMsg == null)
		strErrMsg = "Error in opening DB Connection.";
		%>

		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		  Error in opening connection </font></p>
		<%
		return;
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"PAYROLL","REPORTS",request.getRemoteAddr(),
														"employer_profile.jsp");
if(iAccessLevel == 0){
iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"PAYROLL","CONFIGURATION",request.getRemoteAddr(),
														"employer_profile.jsp");
}
if (strTemp == null) 
	strTemp = "";
//
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
	return;
}

PRRemittance employer = new PRRemittance(request);
String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0");
String strPageAction = WI.fillTextValue("page_action");
String[] astrType = {"","PRIVATE EMPLOYER", "LOCAL GOVERNMENT UNIT","GOVERNMENT CONTROLLED CORP.",
										 "NATIONAL GOVERNMENT AGENCY"};
Vector vEditInfo = null;
Vector vRetResult = null;

if(strPageAction.length() > 0){		
	if(employer.operateOnEmployerProfile(dbOP, Integer.parseInt(strPageAction)) != null)
		strErrMsg = "Operation Successful";
	else
		strErrMsg = employer.getErrMsg();
}

if(strPrepareToEdit.equals("1")){
	vEditInfo = employer.operateOnEmployerProfile(dbOP, 3);
}

vRetResult = employer.operateOnEmployerProfile(dbOP, 4);
%>
<body bgcolor="#D2AE72" class="bgDynamic">
<form action="employer_profile.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" colspan="3" align="center" class="footerDynamic"><font color="#FFFFFF" ><strong>::::
      EMPLOYER DATA ::::</strong></font></td>
    </tr>
    <tr>
      <td height="25" colspan="3">&nbsp;<strong><font size="1"><a href="./remittances_main.jsp"><img src="../../../../images/go_back.gif" width="50" height="27" border="0"></a></font><%=WI.getStrValue(strErrMsg)%></strong></td>
    </tr>
  </table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="5">
    <tr>
      <td width="100%" height="25"><hr size="1">
        <br>
  <table width="95%" border="0" align="center" cellpadding="4" cellspacing="0">
    <% if(vEditInfo != null && vEditInfo.size() > 0)
	   	 strTemp = (String) vEditInfo.elementAt(2);
	   else
		 strTemp = WI.fillTextValue("employer_type");%>
    <tr> 
      <td width="6%">&nbsp;</td>
              <td width="22%">Employer type</td>
              <td width="72%"> 
							<select name="employer_type">
                <option value="1">PRIVATE EMPLOYER</option>
								<%for(int i = 2;i < 5;i++){%>
									<%if (strTemp.equals(Integer.toString(i))){%>
										<option value="<%=i%>" selected><%=astrType[i]%></option>
									<%}else{%>
										<option value="<%=i%>" ><%=astrType[i]%></option>
								<%}%>
								<%}%>
                </select>
							<% 
							if(vEditInfo != null && vEditInfo.size() > 0)
								strTemp = (String)vEditInfo.elementAt(1);
							else	
								strTemp = WI.fillTextValue("is_default");
							strTemp = WI.getStrValue(strTemp,"0");
							
							if(strTemp.compareTo("1") == 0) 
								strTemp = " checked";
							else	
								strTemp = "";	
							%>										
								<input name="is_default" type="checkbox" value="1" <%=strTemp%>>
								Is Main employer</td>
          </tr>
    <tr>
      <td>&nbsp;</td>
      <td>Employer Name </td>
		 <%
		 	 if(vEditInfo != null && vEditInfo.size() > 0)
	   	  strTemp = (String) vEditInfo.elementAt(12);
		   else
		 		strTemp = WI.fillTextValue("employer_name");
				
				if(strTemp == null || strTemp.length() == 0)
					strTemp = SchoolInformation.getSchoolName(dbOP,true,false);
			%>

      <td><input name="employer_name" value="<%=WI.getStrValue(strTemp,"")%>" type= "text" class="textbox"  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"  id="address" size="48"></td>
    </tr>
    <tr> 
      <td width="6%">&nbsp;</td>
	  <td>Address of Employer </td>
	  <% if(vEditInfo != null && vEditInfo.size() > 0)
	   	 	strTemp = (String) vEditInfo.elementAt(3);
	     else
				strTemp = WI.fillTextValue("address");		
				
				if(strTemp == null || strTemp.length() == 0)
					strTemp = SchoolInformation.getAddressLine1(dbOP,false,false);
	  %>
	  <td><input name="address" value="<%=WI.getStrValue(strTemp,"")%>" type= "text" class="textbox"  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"  id="a_address222" size="48"></td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td>Zip Code </td>
	  <% if(vEditInfo != null && vEditInfo.size() > 0)
	   	 	strTemp = (String) vEditInfo.elementAt(4);
	     else
		 	strTemp = WI.fillTextValue("zipcode");
		 
	  %>	  
      <td><input name="zipcode" type="text" value="<%=WI.getStrValue(strTemp,"")%>" size="10" maxlength="6" class="textbox" 
		onFocus="style.backgroundColor='#D3EBFF'" onblur='style.backgroundColor="white"'></td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td>Telephone No. </td>
	  <% if(vEditInfo != null && vEditInfo.size() > 0)
	   	 	strTemp = (String) vEditInfo.elementAt(5);
	     else
		 	strTemp = WI.fillTextValue("phone");
		 
	  %>	  
      <td><input name="phone" value="<%=WI.getStrValue(strTemp,"")%>"  class="textbox" 
	  	  onKeyUp="AllowOnlyIntegerExtn('form_','phone','-')" type="text" size="16" maxlength="16" 
		  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';AllowOnlyIntegerExtn('form_','phone','-')"></td>
    </tr>
    <tr> 
      <td width="6%">&nbsp;</td>
	  <td>SSS Number</td>
	  <% if(vEditInfo != null && vEditInfo.size() > 0)
	   	 	strTemp = (String) vEditInfo.elementAt(6);
	     else
		 	strTemp = WI.fillTextValue("sss");
		 
	  %>	  
	  <td><input name="sss" type= "text" value="<%=WI.getStrValue(strTemp,"")%>" class="textbox"
	  		onKeyUp="AllowOnlyIntegerExtn('form_','sss','-')" size="16" maxlength="16" 
			onBlur="style.backgroundColor='white';AllowOnlyIntegerExtn('form_','sss','-')"
	  	   onfocus="style.backgroundColor='#D3EBFF'"></td>
    </tr>
    <tr> 
      <td width="6%">&nbsp;</td>
	  <td>TIN </td>
	  <% if(vEditInfo != null && vEditInfo.size() > 0)
	   	 	strTemp = (String) vEditInfo.elementAt(7);
	     else
		 	strTemp = WI.fillTextValue("tin");		 
	  %>
	  <td><input name="tin" class="textbox"  value="<%=WI.getStrValue(strTemp,"")%>" 
			onKeyUp="AllowOnlyIntegerExtn('form_','tin','-')" type="text" size="16" maxlength="16" 	  
			onBlur="style.backgroundColor='white';AllowOnlyIntegerExtn('form_','tin','-')"
	  		onFocus="style.backgroundColor='#D3EBFF'" ></td>
    </tr>
    <tr>
      <td>&nbsp;</td>
	  <td>Philhealth</td>
	  <% if(vEditInfo != null && vEditInfo.size() > 0)
	   	 	strTemp = (String) vEditInfo.elementAt(8);
	     else
		 	strTemp = WI.fillTextValue("philhealth");		 
	  %>	  
	  <td><input name="philhealth" class="textbox"  value="<%=WI.getStrValue(strTemp,"")%>" 
		  onKeyUp="AllowOnlyIntegerExtn('form_','philhealth','-')" type="text" size="16" maxlength="16" 	  
		  onBlur="style.backgroundColor='white';AllowOnlyIntegerExtn('form_','philhealth','-')"
		  onFocus="style.backgroundColor='#D3EBFF'"></td>
    </tr>
	<!--
    <tr> 
      <td>&nbsp;</td>
              <td>Pag-ibig</td>
              <td><input name="pag_ibig" type= "text" class="textbox"  value="<%=strTemp2%>" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"  id="tin3" size="16"></td>
          </tr>
	-->
    <tr> 
      <td>&nbsp;</td>
	  <td>PERAA CODE </td>
	  <% if(vEditInfo != null && vEditInfo.size() > 0)
	   	 	strTemp = (String) vEditInfo.elementAt(9);
	     else
		 	strTemp = WI.fillTextValue("peraa");		 
	  %>	  	  
	  <td><input name="peraa" class="textbox"  value="<%=WI.getStrValue(strTemp,"")%>"
		   onKeyUp="AllowOnlyIntegerExtn('form_','peraa','-')" type="text" size="16" maxlength="16" 	  
	  	   onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td>Agency Code </td>
	  <% if(vEditInfo != null && vEditInfo.size() > 0)
	   	 	strTemp = (String) vEditInfo.elementAt(10);
	     else
		 	strTemp = WI.fillTextValue("agency_code");		 
	  %>	  	  
      <td><input name="agency_code" class="textbox"  value="<%=WI.getStrValue(strTemp,"")%>"
		   onKeyUp="AllowOnlyIntegerExtn('form_','agency_code','-')" type="text" size="16" maxlength="16" 	  
	  	   onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
      <font size="1">(for government institutions)</font></td>
    </tr>
    <tr>
      <td>&nbsp;</td>
	  <% if(vEditInfo != null && vEditInfo.size() > 0)
	   	 	strTemp = (String) vEditInfo.elementAt(11);
	     else
		 	strTemp = WI.fillTextValue("region_code");		 
	  %>	  	  
      <td>Region Code </td>
      <td><input name="region_code" class="textbox"  value="<%=WI.getStrValue(strTemp,"")%>"
		   onKeyUp="AllowOnlyIntegerExtn('form_','region_code','-')" type="text" size="16" maxlength="16" 	  
	  	   onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
				 <font size="1">(for government institutions)</font></td>
    </tr>
    <tr> 
      <td width="6%">&nbsp;</td>
			<td>RDO Code </td>
	  <% if(vEditInfo != null && vEditInfo.size() > 0)
	   	 	strTemp = (String) vEditInfo.elementAt(13);
	     else
		 	strTemp = WI.fillTextValue("rdo_code");		 
	  %>	  			
			<td><input name="rdo_code" class="textbox"  value="<%=WI.getStrValue(strTemp,"")%>"
			onKeyUp="AllowOnlyIntegerExtn('form_','rdo_code','-')" type="text" size="16" maxlength="16" 	  
			onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
							<font size="1">(for tax reports)</font></td>
     </tr>
     <tr> 
       <td width="6%">&nbsp;</td>
	   <td colspan="2"><div align="center"> 
		 <% if (iAccessLevel > 1){%>
		 <%if(strPrepareToEdit.compareTo("1") != 0) {%>
		 <!--
		 <a href="javascript:saveRecord();"><img src="../../../../images/save.gif" border="0" name="hide_save"></a> 
		 -->
		 <input type="button" name="save" value=" Save " style="font-size:11px; height:26px;border: 1px solid #FF0000;" onClick="javascript:PageAction(1,'','');">
		 <font size="1">click to save entries</font> 
		 <%}else{%>
		 <!--
		 <a href="javascript:EditRecord();"><img src="../../../../images/edit.gif" border="0"></a>
		 -->
		 <input type="button" name="edit" value=" Edit " style="font-size:11px; height:26px;border: 1px solid #FF0000;" onClick="javascript:PageAction(2,'','');">
		 <font size="1">click to save changes</font>
		 <%}%>
		 <!--
		 <a href='javascript:CancelRecord("")'><img src="../../../../images/cancel.gif" border="0"></a>
		 -->
			<input type="button" name="cancel" value=" Cancel " style="font-size:11px; height:26px;border: 1px solid #FF0000;" 
			onClick="javascript:CancelRecord();">		 
		 <font size="1">click to cancel and clear entries</font> 
		<%}%>
		</div></td>
     </tr>
    </table>
   </td>
 </tr>
</table>
<%if(vRetResult != null && vRetResult.size() > 0){%>
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td height="25" colspan="6" align="center" class="thinborder">EMPLOYERS</td>
    </tr>
    <tr>
      <td width="10%" height="25" align="center" class="thinborder">TYPE</td>
      <td width="35%" align="center" class="thinborder">EMPLOYER </td>
      <td width="12%" align="center" class="thinborder">CONTACT NUMBER </td>
      <td width="27%" align="center" class="thinborder">SSS/ TIN/ PHILHEALTH/ PERAA</td>
      <td colspan="2" align="center" class="thinborder">OPTIONS</td>
    </tr>
    <%for(int iLoop = 0;iLoop < vRetResult.size();iLoop+=23){%>
    <tr>
      <td height="25" class="thinborder">&nbsp;<%=astrType[Integer.parseInt((String)vRetResult.elementAt(iLoop+2))]%></td>
      <%
				strTemp = (String)vRetResult.elementAt(iLoop+12);
				strTemp += WI.getStrValue((String)vRetResult.elementAt(iLoop+3),"<br>","","");
				strTemp += WI.getStrValue((String)vRetResult.elementAt(iLoop+4)," ","","");
			%>			
      <td class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
			<%
				strTemp = (String)vRetResult.elementAt(iLoop+5);
			%>			
      <td class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%>&nbsp;</td>
			<%
				strTemp = WI.getStrValue((String)vRetResult.elementAt(iLoop+6),"SSS : ","","");
				strTemp += WI.getStrValue((String)vRetResult.elementAt(iLoop+7),"<br>TIN : ","","");
				strTemp += WI.getStrValue((String)vRetResult.elementAt(iLoop+8),"<br>Philhealth : ","","");
				strTemp += WI.getStrValue((String)vRetResult.elementAt(iLoop+9),"<br>PERAA : ","","");
			%>			
      <td valign="top" class="thinborder"><%=WI.getStrValue(strTemp, "&nbsp;")%></td>
      <td width="6%" align="center" class="thinborder"><a href="javascript:PageAction(3,'<%=(String)vRetResult.elementAt(iLoop)%>','');"><img src="../../../../images/edit.gif" border="0"></a></td>
      <td width="10%" class="thinborder"><div align="center">
			<%if(!((String)vRetResult.elementAt(iLoop+1)).equals("1")){%>
			<a href="javascript:PageAction(0,'<%=(String)vRetResult.elementAt(iLoop)%>','<%=(String)vRetResult.elementAt(iLoop+12)%>');"><img src="../../../../images/delete.gif" border="0"></a>
			<%}else{%>
				DEFAULT
			  <%}%>
			</div></td>
    </tr>
    <%}%>
  </table>
	<%}%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25"  colspan="3">&nbsp;</td>
    </tr>
    <tr>
      <td height="25"  colspan="3" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="page_action">
<input type="hidden" name="employer_index" value="<%=WI.fillTextValue("employer_index")%>">
<input type="hidden" name="prepareToEdit">
</form>
</body>
</html>
<%
	dbOP.cleanUP();
%>
