<%@ page language="java" import="utility.*, Accounting.CashReceiptBook, java.util.Vector" %>
<%
String strAuthTypeIndex = (String)request.getSession(false).getAttribute("authTypeIndex");
if(strAuthTypeIndex == null || strAuthTypeIndex.equals("4")){%>
	<p style="font-size:14px; font-weight:bold;">You are logged out. Please login again."</p>
<%return;}

WebInterface WI = new WebInterface(request);
DBOperation dbOP = new DBOperation();
String strErrMsg = null;
String strTemp = null;

CashReceiptBook CRB = new CashReceiptBook();
	
	Vector vMapFeeName = new Vector();//[0]map_order [1]fee_name_map
	Vector vMapFeeNameDtls = new Vector();//[0]map_index [1]fee_name_orig [2]fee_name_map [3]map_order
	

    Vector vMainInfo = new Vector();//[0] teller Index, [1] or range, [2] trans_date, [3] cash on hand [4] cash short, [5] total cash
    Vector vTeller   = new Vector();//[0] teller Index, [1] name,     [2] Id.
    Vector vTuition  = new Vector();//[0] date paid,    [1] amount,   [2] teller index

    Vector vTransDate = new Vector();//[0] transaction_date
    Vector vFeeInfo   = new Vector();//[0] fee_name
    Vector vFeeInfoCoa= new Vector();//[0] fee_name, [1] coa
	Vector vFeeCollected = new Vector();//[0] teller_index, [1] date paid, [2] fee_name [3] amount.
	
	Vector vMappedFeeNameForTotal = new Vector();//fee names adds up to show total.
	Vector vMappedFeeToShowDtls   = new Vector(); //fee names that shows details 
	Vector vMappedFeeToShowDtlsInfo = new Vector(); //fee details to show for the mapped fee.. 


Vector vRetResult = CRB.getCashReceiptReportPerTeller(dbOP, request);
if(vRetResult == null)
	strErrMsg = CRB.getErrMsg();
else {
	vMainInfo     = (Vector)vRetResult.remove(0);
	vTeller       = (Vector)vRetResult.remove(0);
	vTuition      = (Vector)vRetResult.remove(0);
	vTransDate    = (Vector)vRetResult.remove(0);
	vFeeInfo      = (Vector)vRetResult.remove(0);
	vFeeInfoCoa   = (Vector)vRetResult.remove(0);
	vFeeCollected = (Vector)vRetResult.remove(0);

	vMapFeeName = CRB.operateOnFeeMapping(dbOP, request, 5);
	if(vMapFeeName == null)
		vMapFeeName = new Vector();
	else{
		vMapFeeNameDtls	 = CRB.operateOnFeeMapping(dbOP, request, 4);
		if(vMapFeeNameDtls == null)
			vMapFeeNameDtls = new Vector();
		else {//I have to make the fee name Original unique.. as there may be chance the fee name original and fee name mapped are the same.
			for(int i = 0; i < vMapFeeNameDtls.size(); i += 6)
				vMapFeeNameDtls.setElementAt(vMapFeeNameDtls.elementAt(i + 1)+"???**", i + 1);
			
			//also update vFeeCollected
			for(int i =0; i < vFeeCollected.size(); i += 4) {
				vFeeCollected.setElementAt(vFeeCollected.elementAt(i + 2)+"???**", i + 2);
			}
			
			for(int i =0; i < vFeeInfo.size(); i += 2) {
				vFeeInfo.setElementAt(vFeeInfo.elementAt(i)+"???**", i);
			}
			
			
			///I have to get here the mapped fee informations. 
			String strSQLQuery = null;
			java.sql.ResultSet rs = null;
			strSQLQuery = "select MAPPED_FEE_NAME, page_option from AC_FEE_COLLECTION_MAP_OTHER_CONF";
			rs = dbOP.executeQuery(strSQLQuery);
			while(rs.next()) {
				if(rs.getInt(2) == 1) 
					vMappedFeeNameForTotal.addElement(rs.getString(1));//fee names to add .. 
				else {
					vMappedFeeToShowDtls.addElement(rs.getString(1));//fee names to show details.
				}
			}
			rs.close();
			
		}
	}
}

String strMapFeeName = "";
String strPrevMapFeeName = "";

double dMappedFeeRowTotal = 0d;
double dMappedFeeGTotal   = 0d;
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src="../../../../../jscript/common.js"></script>
<script language="javascript">

</script>
<body <%if(WI.fillTextValue("print_stat").equals("1")){%> onLoad="window.print();"<%}%>>

<%if(strErrMsg != null){
	dbOP.cleanUP();
%>
<div align="center" style="font-size:12px"><strong><%=strErrMsg%></strong></div>
<%return;}%>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
  <tr>
    <td height="25" align="center" style="font-weight:bold"> <strong>::::  CASH RECEIPTS BOOK  ::::</td>
  </tr>
  <tr bgcolor="#FFFFFF">
    <td height="25"><font size="2"><strong><font color="#0000FF"><%=request.getAttribute("report_format")%></font></strong></font></td>
  </tr>
</table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr style="font-weight:bold;" align="center">
      <td valign="bottom" height="20" class="thinborder" width="5%"><font size="1">DATE</font></td>      
      <td valign="bottom" class="thinborder" width="5%">TELLER ID</td>
      <td valign="bottom" class="thinborder" width="5%"><font size="1">OR NUMBER</font></td>
      <td valign="bottom" class="thinborder" width="5%"><font size="1">CASH ON HAND</font></td>
      <td valign="bottom" class="thinborder" width="5%"><font size="1">TOTAL COLLECTION</font></td>
      <td  valign="bottom" class="thinborder" width="5%"><font size="1">CASH (SHORT)/OVER</font></td>
      <td valign="bottom" class="thinborder" width="5%"><font size="1">ACCOUNTS RECEIVABLE STUDENT</font></td>
      <%
for(int p = 0; p < vMapFeeName.size(); p +=2) {	
%>
      <td valign="bottom" class="thinborder" width="5%"><font size="1"><%=vMapFeeName.elementAt(p + 1)%></font></td>	  
<%}%>
        <td valign="bottom" class="thinborder" width="5%"><font size="1">TOTAL OTHER INCOME</font></td>
		<td valign="bottom" class="thinborder" width="5%"><font size="1">Others</font></td>
		<td valign="bottom" class="thinborder" width="5%"><font size="1">Amount</font></td>
		<td valign="bottom" class="thinborder" width="5%"><font size="1">Sundry</font></td>
		<td valign="bottom" class="thinborder" width="5%"><font size="1">Amount</font></td>
    </tr>
<%
int iIndexOf = 0; int iIndexOf2 = 0;
String strTeller  = null;
String strTuition = null;
String strTellerIndex = null;

String strOthSchFee = null;


double dCashOnHand = 0d;
double dTotalCol   = 0d;
double dCashShort  = 0d;
double dARStudent  = 0d;


int iTemp = 0;
double dTemp = 0d;


//System.out.println("vMapFeeNameDtls: "+vMapFeeNameDtls);
for(int i = 0; i < vTransDate.size(); ++i) {
	iIndexOf = vMainInfo.indexOf((String)vTransDate.elementAt(i));
	if(iIndexOf == -1)
		continue;
	
	strTellerIndex = (String)vMainInfo.elementAt(iIndexOf - 2);
	
	iIndexOf2 = vTeller.indexOf(strTellerIndex);
	if(iIndexOf2 == -1)
		strTeller = "&nbsp;";
	else	
		strTeller = (String)vTeller.elementAt(iIndexOf2 + 2);
	

	

		

	strTuition = null;
	iIndexOf2 = vTuition.indexOf(strTellerIndex);
	if(iIndexOf2 > -1) {			
		if(vTuition.elementAt(iIndexOf2 - 2).equals(vTransDate.elementAt(i))) {
			strTuition = (String)vTuition.elementAt(iIndexOf2 - 1);
			iIndexOf2 = iIndexOf2 - 2;
			vTuition.remove(iIndexOf2);vTuition.remove(iIndexOf2);vTuition.remove(iIndexOf2);
		}
		
	}


dCashOnHand += Double.parseDouble(ConversionTable.replaceString((String)vMainInfo.elementAt(iIndexOf + 1), ",","")) ;
dTotalCol   += Double.parseDouble(ConversionTable.replaceString((String)vMainInfo.elementAt(iIndexOf + 3), ",","")) ;
dCashShort  += Double.parseDouble(ConversionTable.replaceString((String)vMainInfo.elementAt(iIndexOf + 2), ",","")) ;
dARStudent  += Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTuition, "0"), ",","")) ;
%>
    <tr>
      <td height="20" class="thinborder"><%=vTransDate.elementAt(i)%></td>      
      <td height="20" class="thinborder"><%=strTeller%></td>
      <td class="thinborder"><%=vMainInfo.elementAt(iIndexOf - 1)%></td>
      <td class="thinborder" align="right"><%=vMainInfo.elementAt(iIndexOf + 1)%></td>
      <td class="thinborder" align="right"><%=vMainInfo.elementAt(iIndexOf + 3)%></td>
      <td class="thinborder" align="right"><%=vMainInfo.elementAt(iIndexOf + 2)%></td>
      <td class="thinborder" align="right"><%=WI.getStrValue(strTuition, "&nbsp;")%></td>
      <%
strMapFeeName = "";
strPrevMapFeeName = "";


for(int p = 0; p < vMapFeeName.size(); p += 2) {
iIndexOf2 = vFeeCollected.indexOf(strTellerIndex);
strOthSchFee = null;

dTemp = 0d;
iTemp = 0;
for(int x = 0; x < vFeeCollected.size(); x+=4){
	if(!((String)vFeeCollected.elementAt(x + 1)).equals((String)vTransDate.elementAt(i)))
		continue;
		//System.out.println("vFeeCollected.elementAt(x + 2):"+vFeeCollected.elementAt(x + 2)+":");

	/**
	if the collected fee_name exists in the Map Details.
	and the mapfeename is same in the loop
	**/	
	iTemp = vMapFeeNameDtls.indexOf(vFeeCollected.elementAt(x + 2));//to make the name unique.. 
		
	if(iTemp > -1){
		strMapFeeName = (String)vMapFeeNameDtls.elementAt(iTemp + 1);
		/**
		//if(vFeeCollected.elementAt(x + 2).equals("OTHER TRUST FUND") && strMapFeeName.length() < 3) {
			System.out.println("strMapFeeName: "+strMapFeeName);
			System.out.println("vMapFeeName.elementAt(p + 1): "+vMapFeeName.elementAt(p + 1));
			System.out.println("strTellerIndex: "+strTellerIndex);
			System.out.println("vFeeCollected.elementAt(x): "+vFeeCollected.elementAt(x + 2));
			System.out.println("vMapFeeNameDtls.elementAt(iTemp): "+vMapFeeNameDtls.elementAt(iTemp));
			System.out.println("vMapFeeNameDtls.elementAt(iTemp -1): "+vMapFeeNameDtls.elementAt(iTemp -1));
			
		//}
		**/
		
		if(  strMapFeeName.equals((String)vMapFeeName.elementAt(p + 1)) && strTellerIndex.equals((String)vFeeCollected.elementAt(x))  ){			
			dTemp += Double.parseDouble(ConversionTable.replaceString(WI.getStrValue((String)vFeeCollected.elementAt(x+3), "0"), ",","")) ; 
			
			if(vMappedFeeNameForTotal.indexOf(strMapFeeName) > -1) 
				dMappedFeeRowTotal += Double.parseDouble(ConversionTable.replaceString(WI.getStrValue((String)vFeeCollected.elementAt(x+3), "0"), ",","")) ; 

			if(vMappedFeeToShowDtls.indexOf(strMapFeeName) > -1) {
				vMappedFeeToShowDtlsInfo.addElement(vFeeCollected.elementAt(x + 2));
				vMappedFeeToShowDtlsInfo.addElement(vFeeCollected.elementAt(x + 3));
			}
			
			vFeeCollected.remove(x);vFeeCollected.remove(x);vFeeCollected.remove(x);vFeeCollected.remove(x);
			x-=4;
		}
	}
}

if(dTemp == 0d)
	strTemp = "&nbsp;";
else
	strTemp = CommonUtil.formatFloat(dTemp,true);
%>
      <td class="thinborder" width="5%" align="right">
	  <%if(vMappedFeeToShowDtlsInfo.size() == 0){%><font size="1"><%=strTemp%></font>
	  <%}else{%>
		<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
			<%while(vMappedFeeToShowDtlsInfo.size() > 0) {
			strTemp = (String)vMappedFeeToShowDtlsInfo.remove(0);
			strTemp = strTemp.substring(0, strTemp.length() - 5);
			%>
				<tr>
					<td width="50%" class="thinborderBOTTOMRIGHT"><font size="1"><%=strTemp%></font></td>
					<td width="50%" align="right" class="thinborderBOTTOM"><font size="1"><%=vMappedFeeToShowDtlsInfo.remove(0)%></font></td>
				</tr>
			<%}%>
	  	</table>
	  <%}%>
	  </td>
<%}%>
      
	  <!-- total other income -- set in system -->
	  <td class="thinborder" align="right"><%=CommonUtil.formatFloat(dMappedFeeRowTotal, true)%>
	  <%
	  dMappedFeeGTotal += dMappedFeeRowTotal;
	  dMappedFeeRowTotal = 0d;
	  %>
	  </td>

	
	<td class="thinborder" colspan="2" valign="top">
		<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
			<%
			for(int x = 0; x < vFeeCollected.size(); x+=4){
				if(!((String)vFeeCollected.elementAt(x + 1)).equals((String)vTransDate.elementAt(i)))
					continue;
				iTemp = vMapFeeNameDtls.indexOf(vFeeCollected.elementAt(x + 2));
				if(iTemp == -1)
					continue;
				if(  strTellerIndex.equals((String)vFeeCollected.elementAt(x)) 
					&& ((String)vMapFeeNameDtls.elementAt(iTemp + 3)).equals("1") ){//itemize fee name only%>
					
					<tr>
						<td width="50%"><font size="1"><%=vFeeCollected.elementAt(x + 2)%></font></td>
						<td width="50%" align="right"><font size="1"><%=(String)vFeeCollected.elementAt(x+3)%></font></td>
					</tr>
					
				<%									
					vFeeCollected.remove(x);vFeeCollected.remove(x);vFeeCollected.remove(x);vFeeCollected.remove(x);
					x-=4;
				}			
			}
			
			%>
		</table>	</td>
	
	<td class="thinborder" colspan="2" valign="top">
		<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
			<%
			for(int x = 0; x < vFeeCollected.size(); x+=4){
				if(!((String)vFeeCollected.elementAt(x + 1)).equals((String)vTransDate.elementAt(i)))
					continue;
					
				iTemp = vMapFeeNameDtls.indexOf(vFeeCollected.elementAt(x + 2));//this will check if the fee name is mapped
				if(iTemp == -1 && strTellerIndex.equals((String)vFeeCollected.elementAt(x))  ){ //unmapped fee name will go here in sundry
					strTemp = (String)vFeeCollected.elementAt(x + 2);
					strTemp = strTemp.substring(0, strTemp.length() - 5);
				%>
					<tr>
						<td width="50%"><font size="1"><%=strTemp%></font></td>
						<td width="50%" align="right"><font size="1"><%=(String)vFeeCollected.elementAt(x+3)%></font></td>
					</tr>
					<%
					vFeeCollected.remove(x);vFeeCollected.remove(x);vFeeCollected.remove(x);vFeeCollected.remove(x);
					x-=4;
				}	
				else if(  strTellerIndex.equals((String)vFeeCollected.elementAt(x)) 
					&& ((String)vMapFeeNameDtls.elementAt(iTemp + 4)).equals("1") ){//sundry fee name only
					
						strTemp = (String)vFeeCollected.elementAt(x + 2);
						strTemp = strTemp.substring(0, strTemp.length() - 5);

					%>
					
					<tr>
						<td width="50%"><font size="1"><%=strTemp%></font></td>
						<td width="50%" align="right"><font size="1"><%=(String)vFeeCollected.elementAt(x+3)%></font></td>
					</tr>
					
				<%									
					vFeeCollected.remove(x);vFeeCollected.remove(x);vFeeCollected.remove(x);vFeeCollected.remove(x);
					x-=4;
				}			
			}
			
			%>
		</table>	</td>
    </tr>
<%
iIndexOf = iIndexOf - 2;
vMainInfo.remove(iIndexOf);vMainInfo.remove(iIndexOf);vMainInfo.remove(iIndexOf);
vMainInfo.remove(iIndexOf);vMainInfo.remove(iIndexOf);vMainInfo.remove(iIndexOf);





///repeat for multiple tellers.. 
while(true) {
	iIndexOf = vMainInfo.indexOf((String)vTransDate.elementAt(i));
	if(iIndexOf == -1)
		break;

	strTellerIndex = (String)vMainInfo.elementAt(iIndexOf - 2);
	
	iIndexOf2 = vTeller.indexOf(strTellerIndex);
	if(iIndexOf2 == -1)
		strTeller = "&nbsp;";
	else	
		strTeller = (String)vTeller.elementAt(iIndexOf2 + 2);
	


	//get tuition fee.
	strTuition = null;
	iIndexOf2 = vTuition.indexOf(strTellerIndex);
	if(iIndexOf2 > -1) {
		if(vTuition.elementAt(iIndexOf2 - 2).equals(vTransDate.elementAt(i))) {
			strTuition = (String)vTuition.elementAt(iIndexOf2 - 1);
			iIndexOf2 = iIndexOf2 - 2;
			vTuition.remove(iIndexOf2);vTuition.remove(iIndexOf2);vTuition.remove(iIndexOf2);
		}
		
	}
dCashOnHand += Double.parseDouble(ConversionTable.replaceString((String)vMainInfo.elementAt(iIndexOf + 1), ",","")) ;
dTotalCol   += Double.parseDouble(ConversionTable.replaceString((String)vMainInfo.elementAt(iIndexOf + 3), ",","")) ;
dCashShort  += Double.parseDouble(ConversionTable.replaceString((String)vMainInfo.elementAt(iIndexOf + 2), ",","")) ;
dARStudent  += Double.parseDouble(ConversionTable.replaceString(WI.getStrValue(strTuition, "0"), ",","")) ;
%>
    <tr>
      <td height="20" class="thinborder">&nbsp;</td>     
      <td height="20" class="thinborder"><%=strTeller%></td>
      <td class="thinborder"><%=vMainInfo.elementAt(iIndexOf - 1)%></td>
      <td class="thinborder" align="right"><%=vMainInfo.elementAt(iIndexOf + 1)%></td>
      <td class="thinborder" align="right"><%=vMainInfo.elementAt(iIndexOf + 3)%></td>
      <td class="thinborder" align="right"><%=vMainInfo.elementAt(iIndexOf + 2)%></td>
      <td class="thinborder" align="right"><%=WI.getStrValue(strTuition, "&nbsp;")%></td>
      <%for(int p = 0; p < vMapFeeName.size(); p += 2) {
	dTemp = 0d;
	iTemp = 0;
	for(int x = 0; x < vFeeCollected.size(); x+=4){
		if(!((String)vFeeCollected.elementAt(x + 1)).equals((String)vTransDate.elementAt(i)))
			continue;
			
		iTemp = vMapFeeNameDtls.indexOf(vFeeCollected.elementAt(x + 2));
		if(iTemp > -1){
			strMapFeeName = (String)vMapFeeNameDtls.elementAt(iTemp + 1);
			//if(strMapFeeName.equals((String)vMapFeeName.elementAt(p + 1)))		
			if(strMapFeeName.equals((String)vMapFeeName.elementAt(p + 1)) && strTellerIndex.equals((String)vFeeCollected.elementAt(x))){
				dTemp += Double.parseDouble(ConversionTable.replaceString(WI.getStrValue((String)vFeeCollected.elementAt(x+3), "0"), ",","")) ; 				
				vFeeCollected.remove(x);vFeeCollected.remove(x);vFeeCollected.remove(x);vFeeCollected.remove(x);
				x-=4;
			}
		}
	}
	
	if(dTemp == 0d)
		strTemp = "&nbsp;";
	else
		strTemp = CommonUtil.formatFloat(dTemp,true);
%>
      <td class="thinborder" width="5%" align="right"><font size="1"><%=strTemp%></font></td>
<%}
iIndexOf = iIndexOf - 2;
vMainInfo.remove(iIndexOf);vMainInfo.remove(iIndexOf);vMainInfo.remove(iIndexOf);
vMainInfo.remove(iIndexOf);vMainInfo.remove(iIndexOf);vMainInfo.remove(iIndexOf);
%>
    <td class="thinborder" align="right"><%=CommonUtil.formatFloat(dMappedFeeRowTotal, true)%>
	  <%
	  dMappedFeeGTotal += dMappedFeeRowTotal;
	  dMappedFeeRowTotal = 0d;
	  %>
	</td>
	<td class="thinborder" colspan="2" valign="top">
		<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
			<%
			for(int x = 0; x < vFeeCollected.size(); x+=4){
				if(!((String)vFeeCollected.elementAt(x + 1)).equals((String)vTransDate.elementAt(i)))
					continue;
					
				/**
				if the collected fee_name exists in the Map Details.
				and the mapfeename is same in the loop
				**/	
				iTemp = vMapFeeNameDtls.indexOf(vFeeCollected.elementAt(x + 2));
				if(iTemp > -1){					
					if(  strTellerIndex.equals((String)vFeeCollected.elementAt(x)) 
						&& ((String)vMapFeeNameDtls.elementAt(iTemp + 3)).equals("1") ){//itemize fee name only%>
						
						<tr>
							<td width="50%"><font size="1"><%=vFeeCollected.elementAt(x + 2)%></font></td>
							<td width="50%" align="right"><font size="1"><%=(String)vFeeCollected.elementAt(x+3)%></font></td>
						</tr>
						
					<%									
						vFeeCollected.remove(x);vFeeCollected.remove(x);vFeeCollected.remove(x);vFeeCollected.remove(x);
						x-=4;
					}
				}
			}
			
			%>
		</table>	</td>
	<td class="thinborder" colspan="2" valign="top">
		<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
			<%
			for(int x = 0; x < vFeeCollected.size(); x+=4){
				if(!((String)vFeeCollected.elementAt(x + 1)).equals((String)vTransDate.elementAt(i)))
					continue;
				iTemp = vMapFeeNameDtls.indexOf(vFeeCollected.elementAt(x + 2));
				if(iTemp == -1  && strTellerIndex.equals((String)vFeeCollected.elementAt(x)) ){//unmapped fee name%>
					<tr>
						<td width="50%"><font size="1"><%=vFeeCollected.elementAt(x + 2)%></font></td>
						<td width="50%" align="right"><font size="1"><%=(String)vFeeCollected.elementAt(x+3)%></font></td>
					</tr>
					<%
					vFeeCollected.remove(x);vFeeCollected.remove(x);vFeeCollected.remove(x);vFeeCollected.remove(x);
					x-=4;
					
				}else if(  strTellerIndex.equals((String)vFeeCollected.elementAt(x)) 
					&& ((String)vMapFeeNameDtls.elementAt(iTemp + 4)).equals("1") ){//sundry fee name only%>
					
					<tr>
						<td width="50%"><font size="1"><%=vFeeCollected.elementAt(x + 2)%></font></td>
						<td width="50%" align="right"><font size="1"><%=(String)vFeeCollected.elementAt(x+3)%></font></td>
					</tr>
					
				<%									
					vFeeCollected.remove(x);vFeeCollected.remove(x);vFeeCollected.remove(x);vFeeCollected.remove(x);
					x-=4;
				}			
			}
			
			%>
		</table>	</td>
    </tr>
<%}//while (true)


}//end of loop transaction date.%>    
    <tr>
      <td height="20" class="thinborder">TOTAL</td>      
      <td height="20" class="thinborder">&nbsp;</td>
      <td class="thinborder">&nbsp;</td>
      <td class="thinborder" align="right"><%=CommonUtil.formatFloat(dCashOnHand, true)%></td>
      <td class="thinborder" align="right"><%=CommonUtil.formatFloat(dTotalCol, true)%></td>
      <td class="thinborder" align="right"><%=CommonUtil.formatFloat(dCashShort, true)%></td>
      <td class="thinborder" align="right"><%=CommonUtil.formatFloat(dARStudent, true)%></td>
      <%for(int p = 0; p < vMapFeeName.size(); p += 2) {

	dTemp = 0d;
	iTemp = 0;
	for(int x = 0; x < vFeeInfo.size(); x+=2){			
		iTemp = vMapFeeNameDtls.indexOf(vFeeInfo.elementAt(x));
		if(iTemp > -1){
			strMapFeeName = (String)vMapFeeNameDtls.elementAt(iTemp + 1);
			if(strMapFeeName.equals((String)vMapFeeName.elementAt(p + 1)))			
				dTemp += Double.parseDouble(ConversionTable.replaceString(WI.getStrValue((String)vFeeInfo.elementAt(x+1), "0"), ",","")) ; 				
		}
	}
	
	if(dTemp == 0d)
		strTemp = "&nbsp;";
	else
		strTemp = CommonUtil.formatFloat(dTemp,true);

%>
      <td class="thinborder" width="5%" align="right"><font size="1"><%=strTemp%></font></td>
<%}%>

    <td class="thinborder" align="right"><%=CommonUtil.formatFloat(dMappedFeeGTotal, true)%></td>


	<td class="thinborder" width="5%"><font size="1">&nbsp;</font></td>
	
	<%
	dTemp = 0d;
	for(int x = 0; x < vFeeInfo.size(); x+=2){
		iTemp = vMapFeeNameDtls.indexOf(vFeeInfo.elementAt(x));
		if(iTemp > -1){
			strMapFeeName = (String)vMapFeeNameDtls.elementAt(iTemp + 1);
			if(((String)vMapFeeNameDtls.elementAt(iTemp + 3)).equals("1"))			
				dTemp += Double.parseDouble(ConversionTable.replaceString(WI.getStrValue((String)vFeeInfo.elementAt(x+1), "0"), ",","")) ; 				
		}
	}
	
	if(dTemp == 0d)
		strTemp = "&nbsp;";
	else
		strTemp = CommonUtil.formatFloat(dTemp,true);
	%>
	
	<td class="thinborder" width="5%" align="right"><font size="1"><%=strTemp%></font></td>
	<td class="thinborder" width="5%"><font size="1">&nbsp;</font></td>
	<%
	dTemp = 0d;
	for(int x = 0; x < vFeeInfo.size(); x+=2){	
		iTemp = vMapFeeNameDtls.indexOf(vFeeInfo.elementAt(x));
		
		if(iTemp == -1)//unmapped fee name
			dTemp += Double.parseDouble(ConversionTable.replaceString(WI.getStrValue((String)vFeeInfo.elementAt(x+1), "0"), ",","")) ; 
		
		if(iTemp > -1){		
			if(((String)vMapFeeNameDtls.elementAt(iTemp + 4)).equals("1"))			
				dTemp += Double.parseDouble(ConversionTable.replaceString(WI.getStrValue((String)vFeeInfo.elementAt(x+1), "0"), ",","")) ; 				
		}
	}
	
	if(dTemp == 0d)
		strTemp = "&nbsp;";
	else
		strTemp = CommonUtil.formatFloat(dTemp,true);	

	%>
	
	<td class="thinborder" width="5%" align="right"><font size="1"><%=strTemp%></font></td>
    </tr>
  </table>
</body>
</html>
<%
dbOP.cleanUP();
%>